
#pragma once

#include <ESPAsyncWebServer.h>
#include <ArduinoJson.h>
#include <AsyncJson.h>
#include <Update.h>
#include <Ticker.h>

#include <mbedtls/md.h>
#include <mbedtls/base64.h>

#include "rest_common.h"

#define OTA_UPDATE_STATE_IDLE 10
#define OTA_UPDATE_STATE_READY 20
#define OTA_UPDATE_STATE_UPLOAD_FIRMWARE 21
#define OTA_UPDATE_STATE_DONE 22
#define OTA_UPDATE_STATE_ERROR 12

#define OTA_UPDATE_ERROR_NOT_READY 1
#define OTA_UPDATE_ERROR_BAD_HMAC 2

static const size_t _hmacSecretLength = 32;
static const uint8_t _hmacSecret[_hmacSecretLength] = {
    72, 4, 232, 223, 231, 86, 70, 190, 236, 105, 77, 223, 246, 182, 30, 25, 74,
    56, 46, 220, 149, 246, 4, 222, 9, 218, 211, 62, 152, 170, 22, 141
};

class OtaUpdate {

    private:

    AsyncWebServer* _httpServer = nullptr;
    int _otaState = OTA_UPDATE_STATE_IDLE;
    int _errorCode = 0;

    uint32_t _firmwareSize = 0;

    mbedtls_md_context_t _ctx;
    std::string _firmwareHmac = "";

    Ticker _restartTicker;

    public:

    OtaUpdate() {}

    void setup(AsyncWebServer* httpServer) {
        
        if(_httpServer != nullptr) return;
        _httpServer = httpServer;

        // POST /update_prepare

        auto prepareUpdateHandler = new AsyncCallbackJsonWebHandler("/update_prepare", nullptr);
        prepareUpdateHandler->setMethod(HTTP_POST);

        prepareUpdateHandler->onRequest([&](AsyncWebServerRequest *request, JsonVariant &json) {
            _prepareUpdateRequest(request, json);
        });

        _httpServer->addHandler(prepareUpdateHandler);

        // POST /update

        auto firmwareUploadHandler = new AsyncCallbackWebHandler();
        firmwareUploadHandler->setUri("/update");
        firmwareUploadHandler->setMethod(HTTP_POST);

        firmwareUploadHandler->onRequest([&](AsyncWebServerRequest *request) {
            _finishFirmwareUploadRequest(request);
        });

        firmwareUploadHandler->onBody([&](AsyncWebServerRequest *request, uint8_t *data, size_t len, size_t index, size_t total) {
            _handleFirmwareUploadRequest(request, data, len, index, total);
        });

        _httpServer->addHandler(firmwareUploadHandler);

    }

    private:

    void _prepareUpdateRequest(AsyncWebServerRequest *request, JsonVariant &json) {

        if(_otaState != OTA_UPDATE_STATE_IDLE) {
            respondMessage(request, 400, "OTA update je u tijeku");
            return;
        }

        uint32_t size = json["size"];
        std::string hmac = json["hmac"];

        if(size == 0 || size >= 4 * 1024 * 1024 || hmac.length() == 0) {
            respondMessage(request, 400, "Pogrešni podaci");
            return;
        }

        _firmwareSize = size;
        _firmwareHmac = hmac;

        _otaState = OTA_UPDATE_STATE_READY;
        respondMessage(request, 201, "OK");
    }

    void _beginUpdate() {

        if(_otaState != OTA_UPDATE_STATE_READY) {
            _otaState = OTA_UPDATE_STATE_ERROR;
            _errorCode = OTA_UPDATE_ERROR_NOT_READY;
            return;
        }

        _setupHmac();
        Update.begin(_firmwareSize, U_FLASH);

        if(Update.hasError()) {
            _otaState = OTA_UPDATE_STATE_ERROR;
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
        size_t written = Update.write(data, length);

        if(written != length || Update.hasError()) {
            _otaState = OTA_UPDATE_STATE_ERROR;
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
            _errorCode = OTA_UPDATE_ERROR_BAD_HMAC;
            return;
        }

        Update.end(false);

        if(Update.hasError()) {
            _otaState = OTA_UPDATE_STATE_ERROR;
            return;
        }

        _otaState = OTA_UPDATE_STATE_DONE;

    }

    void _handleFirmwareUploadRequest(AsyncWebServerRequest *request, uint8_t *data, size_t len, size_t index, size_t total) {
        
        if(_otaState == OTA_UPDATE_STATE_ERROR) return;

        if(index == 0) {
            _beginUpdate();
        }

        _writeData(data, len);

        if(index + len == total) {
            _finishUpdate();
        }

    }

    void _finishFirmwareUploadRequest(AsyncWebServerRequest *request) {

        if(_otaState == OTA_UPDATE_STATE_DONE) {
            respondMessage(request, 200, "OK");
            _restart();
            return;
        }

        if(_otaState == OTA_UPDATE_STATE_ERROR) {
            if(_errorCode != 0) {
                respondMessage(request, 400, _err2string(_errorCode));
            }else{
                respondMessage(request, 400, Update.errorString());
            }
        }else{
            respondMessage(request, 400, "Nepoznata greška");
        }

        _restart();
    }

    void _setupHmac() {

        mbedtls_md_type_t md_type = MBEDTLS_MD_SHA256;

        mbedtls_md_init(&_ctx);
        mbedtls_md_setup(&_ctx, mbedtls_md_info_from_type(md_type), 1);

        mbedtls_md_hmac_starts(&_ctx, _hmacSecret, _hmacSecretLength);

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

    const char* _err2string(int code) {
        switch (code) {
        case OTA_UPDATE_ERROR_NOT_READY:
            return "OTA update nije spreman";
        case OTA_UPDATE_ERROR_BAD_HMAC:
            return "Program nije valjani";
        default:
            return "Nepoznata greška";
        }
    }

};
