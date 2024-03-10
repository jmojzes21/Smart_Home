
#pragma once

#include <ESPAsyncWebServer.h>
#include <Update.h>
#include <Ticker.h>

#include <mbedtls/md.h>
#include <mbedtls/base64.h>

#include "rest_common.h"
#include "secret.h"

#define OTA_UPDATE_STATE_READY 10
#define OTA_UPDATE_STATE_UPLOAD_FIRMWARE 11
#define OTA_UPDATE_STATE_DONE 12
#define OTA_UPDATE_STATE_ERROR 20

class OtaUpdate {

    private:

    AsyncWebServer* _httpServer = nullptr;
    std::string _deviceType = "";

    int _otaState = OTA_UPDATE_STATE_READY;
    std::string _errorMessage = "";

    uint32_t _firmwareSize = 0;

    mbedtls_md_context_t _ctx;
    std::string _firmwareHmac = "";

    Ticker _restartTicker;

    public:

    OtaUpdate() {}

    void setup(AsyncWebServer* httpServer, const char* deviceType) {
        
        if(_httpServer != nullptr) return;
        _httpServer = httpServer;
        _deviceType = deviceType;

        // POST /firmware_update

        auto updateHandler = new AsyncCallbackWebHandler();
        updateHandler->setUri("/firmware_update");
        updateHandler->setMethod(HTTP_POST);

        updateHandler->onBody([&](AsyncWebServerRequest* request, uint8_t* data, size_t len, size_t index, size_t total) {
            _handleUpdateBody(request, data, len, index, total);
        });

        updateHandler->onRequest([&](AsyncWebServerRequest* request) {
            _handleUpdateRequest(request);
        });

        _httpServer->addHandler(updateHandler);

    }

    private:

    void _prepareUpdate(AsyncWebServerRequest* request) {

        if(_otaState != OTA_UPDATE_STATE_READY) {
            _otaState = OTA_UPDATE_STATE_ERROR;
            _errorMessage = "OTA Update is not ready";
            return;
        }

        auto deviceTypeHeader = request->getHeader("Device-Type");
        auto sizeHeader = request->getHeader("Firmware-Size");
        auto hmacHeader = request->getHeader("Firmware-HMAC");

        if(deviceTypeHeader == nullptr) {
            _otaState = OTA_UPDATE_STATE_ERROR;
            _errorMessage = "No Device type header";
            return;
        }

        if(sizeHeader == nullptr) {
            _otaState = OTA_UPDATE_STATE_ERROR;
            _errorMessage = "No Firmware-Size header";
            return;
        }

        if(hmacHeader == nullptr) {
            _otaState = OTA_UPDATE_STATE_ERROR;
            _errorMessage = "No Firmware-HMAC header";
            return;
        }

        std::string deviceType = std::string(deviceTypeHeader->value().c_str());
        if(deviceType != _deviceType) {
            _otaState = OTA_UPDATE_STATE_ERROR;
            _errorMessage = "Wrong device";
            return;
        }

        uint32_t size = sizeHeader->value().toInt();
        if(size == 0 || size > 2 * 1024 * 1024) {
            _otaState = OTA_UPDATE_STATE_ERROR;
            _errorMessage = "Invalid Firmware size";
            return;
        }

        String hmac = hmacHeader->value();
        if(hmac.length() == 0 || hmac.length() > 60) {
            _otaState = OTA_UPDATE_STATE_ERROR;
            _errorMessage = "Invalid Firmware HMAC";
            return;
        }

        _firmwareSize = size;
        _firmwareHmac = std::string(hmac.c_str());

        _otaState = OTA_UPDATE_STATE_UPLOAD_FIRMWARE;
    }

    void _beginUpdate() {

        if(_otaState != OTA_UPDATE_STATE_UPLOAD_FIRMWARE) {
            _otaState = OTA_UPDATE_STATE_ERROR;
            return;
        }

        _setupHmac();
        Update.begin(_firmwareSize, U_FLASH);

        if(Update.hasError()) {
            _otaState = OTA_UPDATE_STATE_ERROR;
            _errorMessage = Update.errorString();
            return;
        }

        _otaState = OTA_UPDATE_STATE_UPLOAD_FIRMWARE;
    }

    void _writeData(uint8_t* data, size_t length) {

        if(_otaState != OTA_UPDATE_STATE_UPLOAD_FIRMWARE) {
            _otaState = OTA_UPDATE_STATE_ERROR;
            return;
        }

        _updateHmac(data, length);
        Update.write(data, length);

        if(Update.hasError()) {
            _otaState = OTA_UPDATE_STATE_ERROR;
            _errorMessage = Update.errorString();
        }

    }

    void _finishUpdate() {

        if(_otaState != OTA_UPDATE_STATE_UPLOAD_FIRMWARE) {
            _otaState = OTA_UPDATE_STATE_ERROR;
            return;
        }

        std::string actualHmac = _finishHmac();

        if(actualHmac != _firmwareHmac) {
            Update.abort();
            _otaState = OTA_UPDATE_STATE_ERROR;
            _errorMessage = "Firmware HMAC check failed";
            return;
        }

        Update.end(false);

        if(Update.hasError()) {
            _otaState = OTA_UPDATE_STATE_ERROR;
            _errorMessage = Update.errorString();
            return;
        }

        _otaState = OTA_UPDATE_STATE_DONE;

    }

    void _handleUpdateBody(AsyncWebServerRequest* request, uint8_t* data, size_t len, size_t index, size_t total) {
        
        if(_otaState == OTA_UPDATE_STATE_ERROR) return;

        if(index == 0) {
            _prepareUpdate(request);
            _beginUpdate();
        }

        _writeData(data, len);

        if(index + len == total) {
            _finishUpdate();
        }

    }

    void _handleUpdateRequest(AsyncWebServerRequest* request) {

        switch (_otaState) {

            case OTA_UPDATE_STATE_DONE:
                respondMessage(request, 201, "Done");
                _restart();
                return;

            case OTA_UPDATE_STATE_ERROR:
                if(_errorMessage.length() == 0) _errorMessage = "Unknown error";
                respondMessage(request, 400, _errorMessage.c_str());
                _restart();
                return;
            
            case OTA_UPDATE_STATE_READY:
                respondMessage(request, 400, "No body");
                return;

            case OTA_UPDATE_STATE_UPLOAD_FIRMWARE:
                respondMessage(request, 400, "OTA did not finish");
                _restart();
                return;
        }

    }

    void _setupHmac() {

        mbedtls_md_type_t md_type = MBEDTLS_MD_SHA256;

        mbedtls_md_init(&_ctx);
        mbedtls_md_setup(&_ctx, mbedtls_md_info_from_type(md_type), 1);

        mbedtls_md_hmac_starts(&_ctx, hmacSecret, hmacSecretLength);

    }

    void _updateHmac(uint8_t* data, size_t length) {
        mbedtls_md_hmac_update(&_ctx, data, length);
    }

    std::string _finishHmac() {

        uint8_t hmacResult[32];

        mbedtls_md_hmac_finish(&_ctx, hmacResult);
        mbedtls_md_free(&_ctx);

        uint8_t output[64];
        size_t outputLength = 0;

        mbedtls_base64_encode(output, sizeof(output), &outputLength, hmacResult, sizeof(hmacResult));
        
        return std::string((char*)output, outputLength);
    }

    void _restart() {
        _restartTicker.once_ms(2000, []() {
            ESP.restart();
        });
    }

};
