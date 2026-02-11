
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
  AsyncWebSocket* webSocket;

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

  void handleGetConfigRequest(AsyncWebServerRequest* request);
  void handlePatchConfigRequest(AsyncWebServerRequest* request, JsonVariant &jsonv);

  void handleDeviceRestartRequest(AsyncWebServerRequest* request);

  void onSensorData(AirQualityData& aqData);

  void respondJson(AsyncWebServerRequest* request, JsonDocument& doc);
  void respondJson(AsyncWebServerRequest* request, std::string& json);

};
