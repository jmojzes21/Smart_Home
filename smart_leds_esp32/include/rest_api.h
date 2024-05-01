
#pragma once

#include <ArduinoJson.h>
#include <ESPAsyncWebServer.h>

#include "device.h"
#include "led_manager.h"

class DeviceRestApi {

    public:

    void setup();
    
    bool checkAuthentication(AsyncWebServerRequest* request);
    bool authenticate(AsyncWebServerRequest* request);

    void respondJson(AsyncWebServerRequest* request, int code, JsonDocument& doc);
    void respondMessage(AsyncWebServerRequest* request, int code, const char* message);
    void respondCode(AsyncWebServerRequest* request, int code);

    private:

    void _initLedApi();
    void _initDeviceApi();
    void _initWifiApi();
    void _initPowerSensorApi();
    void _initMiscApi();

};
