
#include "RestController.h"

#include <ArduinoJson.h>

RestController::RestController(DeviceController* deviceController, SensorController* sensorController,
  WifiController* wifiController) {
  this->deviceController = deviceController;
  this->sensorController = sensorController;
  this->wifiController = wifiController;
}

void RestController::init() {

  httpServer = new AsyncWebServer(HTTP_SERVER_PORT);

  httpServer->on("/device", HTTP_GET, [&](AsyncWebServerRequest* request) {
    handleDeviceStatusRequest(request);
  });

  httpServer->on("/sensor-data", HTTP_GET, [&](AsyncWebServerRequest* request) {
    handleSensorDataRequest(request);
  });

  httpServer->on("/aq-history", HTTP_GET, [&](AsyncWebServerRequest* request) {
    handleAqHistoryRequest(request);
  });
  
  httpServer->begin();

}

void RestController::handleDeviceStatusRequest(AsyncWebServerRequest* request) {

  auto *ramUsageParam = request->getParam("ram_usage");
  bool showRamUsage = ramUsageParam != nullptr && ramUsageParam->value() == "true";

  auto *vinParam = request->getParam("input_voltage");
  bool showInputVoltage = vinParam != nullptr && vinParam->value() == "true"; 

  JsonDocument doc;

  doc["type"] = DEVICE_TYPE;
  doc["hostname"] = DEVICE_DOMAIN;
  doc["name"] = DEVICE_NAME;
  doc["version"] = DEVICE_VERSION;

  doc["ip"] = wifiController->getLocalIP();
  doc["ssid"] = wifiController->getSSID();
  doc["rssi"] = wifiController->getRSSI();

  if(showRamUsage) {
    JsonObject ram = doc["ram"].to<JsonObject>();

    ram["heap_size"] = ESP.getHeapSize();
    ram["free_heap"] = ESP.getFreeHeap();
    ram["min_free_heap"] = ESP.getMinFreeHeap();
  }

  if(showInputVoltage) {
    uint32_t inputVoltage = sensorController->readInputVoltage();
    doc["input_voltage"] = inputVoltage;
  }

  respondJson(request, doc);

}

void RestController::handleSensorDataRequest(AsyncWebServerRequest* request) {

  auto *detailsParam = request->getParam("details");
  bool showDetails = detailsParam != nullptr && detailsParam->value() == "true"; 

  JsonDocument doc;

  AirQualityData aqData;
  sensorController->readSensorData(aqData);

  JsonObject bme280 = doc["bme280"].to<JsonObject>();
  JsonObject shtc3 = doc["shtc3"].to<JsonObject>();
  JsonObject pms = doc["pms"].to<JsonObject>();

  bme280["temperature"] = aqData.bme280.temperature;
  bme280["humidity"] = aqData.bme280.humidity;
  bme280["pressure"] = aqData.bme280.pressure;

  shtc3["temperature"] = aqData.shtc3.temperature;
  shtc3["humidity"] = aqData.shtc3.humidity;

  pms["pm2.5"] = aqData.pms.pm_25_env;

  if(showDetails) {
    pms["pm1.0"] = aqData.pms.pm_10_env;
    pms["pm10"] = aqData.pms.pm_100_env;

    pms["p0.3"] = aqData.pms.particles_03;
    pms["p0.5"] = aqData.pms.particles_05;
    pms["p1.0"] = aqData.pms.particles_10;
    pms["p2.5"] = aqData.pms.particles_25;
    pms["p5.0"] = aqData.pms.particles_50;
    pms["p10"] = aqData.pms.particles_100;
  }

  respondJson(request, doc);

}

void RestController::handleAqHistoryRequest(AsyncWebServerRequest* request) {

  JsonDocument doc;

  JsonArray aqHistoryJson = doc["aq_history"].to<JsonArray>();

  sensorController->takeAqHistoryMutex();
  auto& aqHistoryList = sensorController->getAirQualityHistory();
  
  for(auto &e : aqHistoryList) {
    JsonObject jsonObj = aqHistoryJson.add<JsonObject>();
    jsonObj["time"] = e.time;
    jsonObj["temperature"] = e.temperature;
    jsonObj["humidity"] = e.humidity;
    jsonObj["pressure"] = e.pressure;
    jsonObj["pm25"] = e.pm25;
  }

  sensorController->giveAqHistoryMutex();

  doc.shrinkToFit();
  respondJson(request, doc);

}

void RestController::respondJson(AsyncWebServerRequest* request, JsonDocument& doc) {
  
  AsyncResponseStream* response = request->beginResponseStream("application/json");

  serializeJson(doc, *response);
  request->send(response);
}
