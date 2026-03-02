
#pragma once

#include <Arduino.h>
#include <string>
#include <vector>
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
  AsyncAuthenticationMiddleware* authMiddleware;

  //std::string secretKey;
  //std::vector<std::string> validTokens;

  public:
  
  RestController(DeviceController* deviceController, SensorController* sensorController,
    WifiController* wifiController);

  void init();

  private:

  void handleGetDeviceRequest(AsyncWebServerRequest* request);
  void handleGetDeviceStatusRequest(AsyncWebServerRequest* request);
  void handleGetSensorDataRequest(AsyncWebServerRequest* request);
  void handleGetAqHistoryRequest(AsyncWebServerRequest* request);
  void handleDeleteAqHistoryRequest(AsyncWebServerRequest* request);

  void handleGetConfigRequest(AsyncWebServerRequest* request);
  void handlePatchConfigRequest(AsyncWebServerRequest* request, JsonVariant &jsonv);

  void handleSyncTimeRequest(AsyncWebServerRequest* request, JsonVariant &jsonv);
  void handleDeviceRestartRequest(AsyncWebServerRequest* request);

  void onSensorData(AirQualityData& aqData);

  bool handleAuthentification(AsyncWebServerRequest *request);

  void respondJson(AsyncWebServerRequest* request, JsonDocument& doc);
  void respondJson(AsyncWebServerRequest* request, std::string& json);

  void sendHistoryData(struct tm time, AirQualityHistory& aqData);

};
