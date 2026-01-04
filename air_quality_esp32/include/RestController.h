
#pragma once

#include <Arduino.h>
#include <ESPAsyncWebServer.h>

#include "DeviceController.h"
#include "SensorController.h"
#include "WifiController.h"

class RestController {

  private:

  DeviceController* deviceController;
  SensorController* sensorController;
  WifiController* wifiController;

  AsyncWebServer* httpServer;

  public:
  
  RestController(DeviceController* deviceController, SensorController* sensorController,
    WifiController* wifiController);

  void init();

  private:

  void handleDeviceStatusRequest(AsyncWebServerRequest* request);
  void handleSensorDataRequest(AsyncWebServerRequest* request);
  void handleGetAqHistoryRequest(AsyncWebServerRequest* request);
  void handleDeleteAqHistoryRequest(AsyncWebServerRequest* request);
  void handleGetRtcRequest(AsyncWebServerRequest* request);
  void handlePatchRtcRequest(AsyncWebServerRequest* request, JsonVariant &jsonv);

  void respondJson(AsyncWebServerRequest* request, JsonDocument& doc);

};
