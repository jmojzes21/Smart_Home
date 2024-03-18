
#pragma once

#include <ESPAsyncWebServer.h>
#include <Update.h>

#include <mbedtls/md.h>
#include <mbedtls/base64.h>

#include "types.h"
#include "device.h"

class OtaUpdate {

    private:

    int _otaState = 0;
    std::string _errorMessage = "";

    uint32_t _firmwareSize = 0;

    mbedtls_md_context_t _ctx;
    std::string _firmwareHmac = "";

    public:

    OtaUpdate();

    void setup();

    private:

    void _prepareUpdate(AsyncWebServerRequest* request);

    void _beginUpdate();
    void _writeData(uint8_t* data, size_t length);
    void _finishUpdate();

    void _handleUpdateBody(AsyncWebServerRequest* request, uint8_t* data, size_t len, size_t index, size_t total);
    void _handleUpdateRequest(AsyncWebServerRequest* request);
    
    void _setupHmac();
    void _updateHmac(uint8_t* data, size_t length);
    std::string _finishHmac();

    void _restart();

};
