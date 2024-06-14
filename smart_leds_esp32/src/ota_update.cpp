
#include "ota_update.h"
#include "rest_api.h"

#include "secret.h"

#define OTA_UPDATE_STATE_READY 10
#define OTA_UPDATE_STATE_UPLOAD_FIRMWARE 11
#define OTA_UPDATE_STATE_DONE 12
#define OTA_UPDATE_STATE_ERROR 20

extern AsyncWebServer httpServer;
extern DeviceRestApi restApi;
extern Device device;

OtaUpdate::OtaUpdate() {
    _otaState = OTA_UPDATE_STATE_READY;
}

void OtaUpdate::setup() {

    Serial.printf("Postavi OTA update\n");
    
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

    httpServer.addHandler(updateHandler);

}

void OtaUpdate::_prepareUpdate(AsyncWebServerRequest* request) {

    if(_otaState != OTA_UPDATE_STATE_READY) {
        _otaState = OTA_UPDATE_STATE_ERROR;
        _errorMessage = "OTA Update is not ready";
        return;
    }

    if(restApi.checkAuthentication(request) == false) {
        _otaState = OTA_UPDATE_STATE_ERROR;
        _errorMessage = "Authentication failed";
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
    if(deviceType != device.deviceType) {
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

void OtaUpdate::_beginUpdate() {

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

void OtaUpdate::_writeData(uint8_t* data, size_t length) {

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

void OtaUpdate::_finishUpdate() {

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

void OtaUpdate::_handleUpdateBody(AsyncWebServerRequest* request, uint8_t* data, size_t len, size_t index, size_t total) {
    
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

void OtaUpdate::_handleUpdateRequest(AsyncWebServerRequest* request) {

    switch (_otaState) {

        case OTA_UPDATE_STATE_DONE:
            restApi.respondMessage(request, 201, "Done");
            _restart();
            return;

        case OTA_UPDATE_STATE_ERROR:
            if(_errorMessage.length() == 0) _errorMessage = "Unknown error";
            restApi.respondMessage(request, 400, _errorMessage.c_str());
            _restart();
            return;
        
        case OTA_UPDATE_STATE_READY:
            restApi.respondMessage(request, 400, "No body");
            return;

        case OTA_UPDATE_STATE_UPLOAD_FIRMWARE:
            restApi.respondMessage(request, 400, "OTA did not finish");
            _restart();
            return;
    }

}

void OtaUpdate::_setupHmac() {

    mbedtls_md_type_t md_type = MBEDTLS_MD_SHA256;

    mbedtls_md_init(&_ctx);
    mbedtls_md_setup(&_ctx, mbedtls_md_info_from_type(md_type), 1);

    mbedtls_md_hmac_starts(&_ctx, hmacSecret, hmacSecretLength);

}

void OtaUpdate::_updateHmac(uint8_t* data, size_t length) {
    mbedtls_md_hmac_update(&_ctx, data, length);
}

std::string OtaUpdate::_finishHmac() {

    uint8_t hmacResult[32];

    mbedtls_md_hmac_finish(&_ctx, hmacResult);
    mbedtls_md_free(&_ctx);

    uint8_t output[64];
    size_t outputLength = 0;

    mbedtls_base64_encode(output, sizeof(output), &outputLength, hmacResult, sizeof(hmacResult));
    
    return std::string((char*)output, outputLength);
}

void OtaUpdate::_restart() {
    device.restart(2000);
}
