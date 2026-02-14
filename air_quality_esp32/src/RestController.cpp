
#include "RestController.h"

#include <ArduinoJson.h>
#include "helpers/DateFormats.h"
#include "helpers/PSRAMAllocator.h"
#include "helpers/Jwt.h"

#define DEVICE_RESTART_DELAY 2000

void sensorDataToJson(AirQualityData& aqData, JsonDocument& doc, bool showDetails);
void metricsToJson(Metrics& metrics, JsonObject& jsonObj);

RestController::RestController(DeviceController* deviceController, SensorController* sensorController,
  WifiController* wifiController) {
  this->deviceController = deviceController;
  this->sensorController = sensorController;
  this->wifiController = wifiController;
}

void RestController::init() {

  secretKey = deviceController->getConfig().secretKey;

  httpServer = new AsyncWebServer(HTTP_SERVER_PORT);
  webSocket = new AsyncWebSocket("/sensor-data-ws");

  httpServer->on("/device", HTTP_GET, [&](AsyncWebServerRequest* request) {
    handleGetDeviceRequest(request);
  });

  httpServer->on("/device-status", HTTP_GET, [&](AsyncWebServerRequest* request) {
    handleGetDeviceStatusRequest(request);
  });

  httpServer->on("/sensor-data", HTTP_GET, [&](AsyncWebServerRequest* request) {
    handleGetSensorDataRequest(request);
  });

  httpServer->on("/aq-history", HTTP_GET, [&](AsyncWebServerRequest* request) {
    handleGetAqHistoryRequest(request);
  });

  httpServer->on("/aq-history", HTTP_DELETE, [&](AsyncWebServerRequest* request) {
    handleDeleteAqHistoryRequest(request);
  });

  httpServer->on("/rtc", HTTP_GET, [&](AsyncWebServerRequest* request) {
    handleGetRtcRequest(request);
  });

  httpServer->on("/rtc", HTTP_PATCH, [&](AsyncWebServerRequest* request, JsonVariant &jsonv) {
    handlePatchRtcRequest(request, jsonv);
  });

  httpServer->on("/config", HTTP_GET, [&](AsyncWebServerRequest* request) {
    handleGetConfigRequest(request);
  });

  httpServer->on("/config", HTTP_PATCH, [&](AsyncWebServerRequest* request, JsonVariant &jsonv) {
    handlePatchConfigRequest(request, jsonv);
  });

  httpServer->on("/restart", HTTP_POST, [&](AsyncWebServerRequest* request) {
    handleDeviceRestartRequest(request);
  });
  
  webSocket->onEvent([&](AsyncWebSocket *server, AsyncWebSocketClient *client, AwsEventType type, void *arg, uint8_t *data, size_t len) {
    switch(type) {
      case WS_EVT_CONNECT: {
        log_i("WebSocket client connected %ld", client->id());
        break;
      }
      case WS_EVT_DISCONNECT: {
        log_i("WebSocket client disconnected %ld", client->id());
        break;
      }
    }
  });

  authMiddleware = new AsyncAuthenticationMiddleware();
  authMiddleware->setAuthType(AsyncAuthType::AUTH_BEARER);
  authMiddleware->setAuthentificationFunction([&](AsyncWebServerRequest* request) {
    return handleAuthentification(request);
  });

  httpServer->addMiddleware(authMiddleware);

  httpServer->addHandler(webSocket);
  httpServer->begin();

  sensorController->setOnSensorData([&](AirQualityData& aqData){
    onSensorData(aqData);
  });

}

void RestController::handleGetDeviceRequest(AsyncWebServerRequest* request) {

  auto& config = deviceController->getConfig();

  JsonDocument doc;

  doc["name"] = config.deviceName;
  doc["hostname"] = config.hostname;
  doc["type"] = DEVICE_TYPE;
  doc["version"] = DEVICE_VERSION;
  
  doc["ip"] = wifiController->getLocalIP();
  doc["ssid"] = wifiController->getSSID();
  doc["rssi"] = wifiController->getRSSI();

  respondJson(request, doc);

}

void RestController::handleGetDeviceStatusRequest(AsyncWebServerRequest* request) {

  auto *ramUsageParam = request->getParam("ram_usage");
  bool showRamUsage = ramUsageParam != nullptr && ramUsageParam->value() == "true";

  auto *vinParam = request->getParam("input_voltage");
  bool showInputVoltage = vinParam != nullptr && vinParam->value() == "true"; 

  auto& config = deviceController->getConfig();

  JsonDocument doc;

  doc["name"] = config.deviceName;
  doc["hostname"] = config.hostname;
  doc["type"] = DEVICE_TYPE;
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

void RestController::handleGetSensorDataRequest(AsyncWebServerRequest* request) {

  auto *detailsParam = request->getParam("details");
  bool showDetails = detailsParam != nullptr && detailsParam->value() == "true"; 

  AirQualityData aqData = sensorController->getAirQuality();
  JsonDocument doc;
  
  sensorDataToJson(aqData, doc, showDetails);

  respondJson(request, doc);

}

void RestController::handleGetAqHistoryRequest(AsyncWebServerRequest* request) {

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

    JsonObject temp = jsonObj["temperature"].to<JsonObject>();
    JsonObject hum = jsonObj["humidity"].to<JsonObject>();
    JsonObject press = jsonObj["pressure"].to<JsonObject>();
    JsonObject pm = jsonObj["pm25"].to<JsonObject>();

    metricsToJson(e.temperatureMetrics, temp);
    metricsToJson(e.humidityMetrics, hum);
    metricsToJson(e.pressureMetrics, press);
    metricsToJson(e.pm25Metrics, pm);
  }

  sensorController->giveAqHistoryMutex();

  doc.shrinkToFit();
  respondJson(request, doc);

}

void RestController::handleDeleteAqHistoryRequest(AsyncWebServerRequest *request) {

  sensorController->clearAirQualityHistory();

  request->send(200);
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
  t.tm_wday = (int)json["week_day"];
  t.tm_mday = (int)json["month_day"];
  t.tm_mon = (int)json["month"] - 1;
  t.tm_year = (int)json["year"] - 1900;
  t.tm_hour = (int)json["hour"];
  t.tm_min = (int)json["minute"];
  t.tm_sec = (int)json["second"];

  deviceController->setDateTime(t);
  t = deviceController->getDateTime();

  JsonDocument doc;

  std::string dateTime = DateFormats::formatDateTime(t);
  doc["date_time"] = dateTime;

  respondJson(request, doc);

}


void RestController::handleGetConfigRequest(AsyncWebServerRequest *request) {

  auto& config = deviceController->getConfig();
  std::string configJson = config.toJson();

  respondJson(request, configJson);
}

void RestController::handlePatchConfigRequest(AsyncWebServerRequest *request, JsonVariant &jsonv) {

  JsonObject json = jsonv.as<JsonObject>();

  std::string configJson;
  serializeJson(json, configJson);

  DeviceConfig config;
  if(!config.parse(configJson)) {
    request->send(400);
  }

  configJson = config.toJson();

  deviceController->writeConfigFile(configJson);
  deviceController->readConfig();

  respondJson(request, configJson);
}

void RestController::handleDeviceRestartRequest(AsyncWebServerRequest *request) {
  deviceController->restart(DEVICE_RESTART_DELAY);
  request->send(201);
}

void RestController::onSensorData(AirQualityData &aqData) {

  webSocket->cleanupClients();

  JsonDocument doc;
  sensorDataToJson(aqData, doc, true);

  std::string msg = "sensor-data;";
  serializeJson(doc, msg);

  webSocket->textAll(msg.c_str(), msg.length());

}


bool RestController::handleAuthentification(AsyncWebServerRequest *request) {

  /*
  std::string tokenText = request->authChallenge().c_str();

  if(tokenText.empty()) {
    if(request->method() == HTTP_GET && request->url() == "/device") {
      return true;
    }
    return false;
  }

  auto result = std::find(validTokens.begin(), validTokens.end(), tokenText);
  if(result != validTokens.end()) {
    return true;
  }
  
  JwtToken token;

  if(!token.decode(secretKey, tokenText)) {
    return false;
  }

  struct tm timeInfo = deviceController->getDateTime();
  uint32_t time = mktime(&timeInfo);

  if(!token.isValid(time)) {
    log_i("Token is not valid, time: %ld", time);
    return false;
  }

  validTokens.push_back(tokenText);
  */

  return true;
}

void RestController::respondJson(AsyncWebServerRequest* request, JsonDocument& doc) {
  
  std::string json;
  serializeJson(doc, json);

  respondJson(request, json);

}

void RestController::respondJson(AsyncWebServerRequest *request, std::string &json) {

  AsyncResponseStream* response = request->beginResponseStream("application/json");

  response->write(json.c_str(), json.length());
  request->send(response);

}


void sensorDataToJson(AirQualityData& aqData, JsonDocument& doc, bool showDetails) {

  doc["temperature"] = aqData.temperature;
  doc["humidity"] = aqData.humidity;
  doc["pressure"] = aqData.pressure;
  doc["pm2.5"] = aqData.pms.pm_25_env;

  if(showDetails) {
    JsonObject bme280 = doc["bme280"].to<JsonObject>();
    JsonObject shtc3 = doc["shtc3"].to<JsonObject>();
    JsonObject pms = doc["pms"].to<JsonObject>();

    bme280["temperature"] = aqData.bme280.temperature;
    bme280["humidity"] = aqData.bme280.humidity;
    bme280["pressure"] = aqData.bme280.pressure;

    shtc3["temperature"] = aqData.shtc3.temperature;
    shtc3["humidity"] = aqData.shtc3.humidity;

    pms["pm1.0"] = aqData.pms.pm_10_env;
    pms["pm2.5"] = aqData.pms.pm_25_env;
    pms["pm10"] = aqData.pms.pm_100_env;

    pms["p0.3"] = aqData.pms.particles_03;
    pms["p0.5"] = aqData.pms.particles_05;
    pms["p1.0"] = aqData.pms.particles_10;
    pms["p2.5"] = aqData.pms.particles_25;
    pms["p5.0"] = aqData.pms.particles_50;
    pms["p10"] = aqData.pms.particles_100;
  }

}

void metricsToJson(Metrics& metrics, JsonObject& jsonObj) {
  jsonObj["average"] = (float)metrics.getAverage();
  jsonObj["min"] = (float)metrics.getMinValue();
  jsonObj["max"] = (float)metrics.getMaxValue();
}
