
#pragma once

#include <ArduinoJson.h>
#include <ESPAsyncWebServer.h>

#include "types.h"
#include "device.h"
#include "led_manager.h"

void respondJson(AsyncWebServerRequest* request, int code, JsonDocument& doc);
void respondMessage(AsyncWebServerRequest* request, int code, const char* message);

class DeviceRestApi {

    public:

    void setup();
    
};
