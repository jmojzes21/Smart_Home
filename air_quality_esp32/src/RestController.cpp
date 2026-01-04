
#include "RestController.h"

#include <ArduinoJson.h>
#include "DateFormats.h"
#include "PSRAMAllocator.h"

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

  httpServer->on("/rtc", HTTP_GET, [&](AsyncWebServerRequest* request) {
    handleGetRtcRequest(request);
  });

  httpServer->on("/rtc", HTTP_PATCH, [&](AsyncWebServerRequest* request, JsonVariant &jsonv) {
    handlePatchRtcRequest(request, jsonv);
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

    ram["psram_size"] = ESP.getPsramSize();
    ram["free_psram"] = ESP.getFreePsram();
    ram["min_free_psram"] = ESP.getMinFreePsram();
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

  SpiRamAllocator allocator;
  JsonDocument doc(&allocator);

  tm bootTime = deviceController->getBootTime();
  std::string bootTimeText = DateFormats::formatDateTime(bootTime);
  doc["boot_time"] = bootTimeText;

  JsonArray aqHistoryJson = doc["aq_history"].to<JsonArray>();

  sensorController->takeAqHistoryMutex();
  auto& aqHistoryList = sensorController->getAirQualityHistory();
  
  for(auto &e : aqHistoryList) {
    JsonObject jsonObj = aqHistoryJson.add<JsonObject>();
    jsonObj["time"] = e.timeSeconds;
    jsonObj["temperature"] = e.temperature;
    jsonObj["humidity"] = e.humidity;
    jsonObj["pressure"] = e.pressure;
    jsonObj["pm25"] = e.pm25;
  }

  sensorController->giveAqHistoryMutex();

  doc.shrinkToFit();
  respondJson(request, doc);

}

void RestController::handleGetRtcRequest(AsyncWebServerRequest *request) {

  tm t = deviceController->getDateTime();

  JsonDocument doc;

  std::string dateTime = DateFormats::formatDateTime(t);
  doc["date_time"] = dateTime;

  respondJson(request, doc);

}

void RestController::handlePatchRtcRequest(AsyncWebServerRequest *request, JsonVariant &jsonv) {

  JsonObject json = jsonv.as<JsonObject>();

  tm t = {0};
  t.tm_wday = json["week_day"];
  t.tm_mday = json["month_day"];
  t.tm_mon = json["month"];
  t.tm_year = json["year"];
  t.tm_hour = json["hour"];
  t.tm_min = json["minute"];
  t.tm_sec = json["second"];

  deviceController->setDateTime(t);
  t = deviceController->getDateTime();

  JsonDocument doc;

  std::string dateTime = DateFormats::formatDateTime(t);
  doc["date_time"] = dateTime;

  respondJson(request, doc);

}

void RestController::respondJson(AsyncWebServerRequest* request, JsonDocument& doc) {
  
  AsyncResponseStream* response = request->beginResponseStream("application/json");

  serializeJson(doc, *response);
  request->send(response);
}
