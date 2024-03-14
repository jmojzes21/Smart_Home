
#pragma once

#include <ArduinoJson.h>
#include <ESPAsyncWebServer.h>
#include <AsyncJson.h>

#include "types.h"
#include "device.h"
#include "pattern_manager.h"

void respondJson(AsyncWebServerRequest* request, int code, JsonDocument& doc);
void respondMessage(AsyncWebServerRequest* request, int code, const char* message);

class DeviceRestApi {

    private:

    AsyncWebServer* _httpServer = nullptr;
    Device* _device = nullptr;
    PatternManager* _patternManager = nullptr;
    VoidCallback _onRestart = nullptr;

    public:

    void setup(AsyncWebServer* httpServer, Device* device, PatternManager* patternManager, VoidCallback onRestart);
    
};
