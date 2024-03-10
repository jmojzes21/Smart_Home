
#pragma once

#include <ArduinoJson.h>
#include <ESPAsyncWebServer.h>
#include <AsyncJson.h>

#include "types.h"
#include "device.h"

void respondJson(AsyncWebServerRequest* request, int code, JsonDocument& doc);
void respondMessage(AsyncWebServerRequest* request, int code, const char* message);

class DeviceRestApi {

    private:

    AsyncWebServer* _httpServer = nullptr;
    Device* _device = nullptr;
    VoidCallback _onRestart = nullptr;

    public:

    void setup(AsyncWebServer* httpServer, Device* device, VoidCallback onRestart);
    
};
