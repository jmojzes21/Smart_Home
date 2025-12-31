
#include <Arduino.h>
#include <WiFi.h>
#include <ESPAsyncWebServer.h>
#include <ESPmDNS.h>
#include <Adafruit_BME280.h>
#include <SHTC3-SOLDERED.h>
#include <ArduinoJson.h>
#include <LittleFS.h>

#include "DasduinoLed.h"
#include "PMS5003.h"

#include <list>

#define DEVICE_HOSTNAME "air-quality-sensor"
#define DEVICE_DOMAIN "air-quality-sensor.local"
#define DEVICE_NAME "Kvaliteta zraka"
#define DEVICE_TYPE "air_quality"
#define DEVICE_VERSION "v0.1.0"

#define MDNS_SERVICE "smart-home"
#define HTTP_SERVER_PORT 80

#define WIFI_CONNECT_TIMEOUT 5000
#define SAVE_AQ_HISTORY_PERIOD 60000

#define PMS_RX_PIN 14
#define PMS_TX_PIN 15

struct AirQualityHistory {
  uint64_t time;
  float temperature;
  float humidity;
  float pressure;
  uint16_t pm25;
};

Adafruit_BME280 bme280Sensor;
SHTC3 shtc3Sensor;
SemaphoreHandle_t sensorMutex;

AsyncWebServer httpServer(HTTP_SERVER_PORT);

PMS5003_Sensor pms5003Sensor;
PMS5003_Data pmsData;
SemaphoreHandle_t pmsMutex;

std::list<AirQualityHistory> aqHistory;
uint64_t saveAqHistoryTime = 0;

void connectWifi();
void initHttpServer();
void initMdns();
void haltDevice();

void setup() {

  Serial.begin(115200);

  DasduinoLed::init();
  DasduinoLed::setBrightness(20);

  Wire.begin();

  if(!bme280Sensor.begin(BME280_ADDRESS_ALTERNATE)) {
    DasduinoLed::showColor(DasduinoLed::Orange);
    haltDevice();
  }

  if(!shtc3Sensor.begin()) {
    DasduinoLed::showColor(DasduinoLed::Orange);
    haltDevice();
  }

  pms5003Sensor.init(&Serial2, PMS_RX_PIN, PMS_TX_PIN);

  sensorMutex = xSemaphoreCreateMutex();
  pmsMutex = xSemaphoreCreateMutex();

  connectWifi();
  initHttpServer();
  initMdns();

  delay(200);
  saveAqHistoryTime = millis() + SAVE_AQ_HISTORY_PERIOD;

}

void saveAirQualityHistory() {

  xSemaphoreTake(sensorMutex, portMAX_DELAY);

  float bme280Temperature = bme280Sensor.readTemperature();
  float bme280Humidity = bme280Sensor.readHumidity();
  float bme280Pressure = bme280Sensor.readPressure() / 100.0f;

  shtc3Sensor.sample();
  float shtc3Temperature = shtc3Sensor.readTempC();
  float shtc3Humidity = shtc3Sensor.readHumidity();

  xSemaphoreGive(sensorMutex);

  xSemaphoreTake(pmsMutex, portMAX_DELAY);
  uint16_t pm25 = pmsData.pm_25_env;
  xSemaphoreGive(pmsMutex);

  AirQualityHistory aqh;
  aqh.time = millis() / 1000;

  aqh.temperature = (bme280Temperature + shtc3Temperature) / 2;
  aqh.humidity = (bme280Humidity + shtc3Humidity) / 2;
  aqh.pressure = bme280Pressure;
  aqh.pm25 = pm25;

  while(aqHistory.size() >= 400) {
    aqHistory.pop_front();
  }

  aqHistory.push_back(aqh);

}

void loop() {

  uint64_t now = millis();
  if(now >= saveAqHistoryTime) {
    saveAqHistoryTime = now + SAVE_AQ_HISTORY_PERIOD;
    saveAirQualityHistory();
  }

  PMS5003_Data tdata;
  if(pms5003Sensor.read(&tdata)) {
    xSemaphoreTake(pmsMutex, portMAX_DELAY);
    pmsData = tdata;
    xSemaphoreGive(pmsMutex);
  }

  delay(2000);
}

void connectWifi() {

  JsonDocument document;

  LittleFS.begin(true);

  File file = LittleFS.open("/wifi.json", FILE_READ);

  if(!file) {
    DasduinoLed::showColor(DasduinoLed::Orange);
    haltDevice();
  }

  deserializeJson(document, file);
  file.close();

  LittleFS.end();

  String ssid = document["ssid"];
  String password = document["password"];

  DasduinoLed::showColor(DasduinoLed::Blue);

  WiFi.mode(WIFI_STA);
  WiFi.begin(ssid, password);

  uint32_t startTime = millis();

  while(!WiFi.isConnected()) {
    if(millis() - startTime >= WIFI_CONNECT_TIMEOUT) {
      break;
    }

    delay(200);
  }

  if(!WiFi.isConnected()) {
    DasduinoLed::showColor(DasduinoLed::Orange);
    haltDevice();
  }

  DasduinoLed::clear();

}

void readSensorData(JsonDocument& document, bool showDetails) {
  
  JsonObject bme280 = document["bme280"].to<JsonObject>();
  JsonObject shtc3 = document["shtc3"].to<JsonObject>();

  xSemaphoreTake(sensorMutex, portMAX_DELAY);

  bme280["temperature"] = (float)bme280Sensor.readTemperature();
  bme280["humidity"] = (float)bme280Sensor.readHumidity();
  bme280["pressure"] = (float)(bme280Sensor.readPressure() / 100.0f);

  shtc3Sensor.sample();
  shtc3["temperature"] = (float)shtc3Sensor.readTempC();
  shtc3["humidity"] = (float)shtc3Sensor.readHumidity();

  xSemaphoreGive(sensorMutex);

  JsonObject pms = document["pms"].to<JsonObject>();

  xSemaphoreTake(pmsMutex, portMAX_DELAY);

  pms["pm2.5"] = pmsData.pm_25_env;

  if(showDetails) {
    pms["pm1.0"] = pmsData.pm_10_env;
    pms["pm10"] = pmsData.pm_100_env;

    pms["p0.3"] = pmsData.particles_03;
    pms["p0.5"] = pmsData.particles_05;
    pms["p1.0"] = pmsData.particles_10;
    pms["p2.5"] = pmsData.particles_25;
    pms["p5.0"] = pmsData.particles_50;
    pms["p10"] = pmsData.particles_100;
  }

  xSemaphoreGive(pmsMutex);

}

void handleSensorDataRequest(AsyncWebServerRequest* request) {

  auto *detailsParam = request->getParam("details");
  bool showDetails = detailsParam != nullptr && detailsParam->value() == "true"; 

  JsonDocument document;
  readSensorData(document, showDetails);

  AsyncResponseStream* response = request->beginResponseStream("application/json");

  serializeJson(document, *response);
  request->send(response);

}

void handleDeviceStatusRequest(AsyncWebServerRequest* request) {

  JsonDocument doc;

  doc["name"] = DEVICE_NAME;
  doc["domain"] = DEVICE_DOMAIN;
  doc["type"] = DEVICE_TYPE;
  doc["version"] = DEVICE_VERSION;

  doc["ip"] = WiFi.localIP().toString();
  doc["mac"] = WiFi.macAddress();
  doc["ssid"] = WiFi.SSID();
  doc["rssi"] = (int)WiFi.RSSI();

  JsonObject ram = doc["ram"].to<JsonObject>();

  ram["heap_size"] = ESP.getHeapSize();
  ram["free_heap"] = ESP.getFreeHeap();
  ram["min_free_heap"] = ESP.getMinFreeHeap();

  AsyncResponseStream* response = request->beginResponseStream("application/json");

  serializeJson(doc, *response);
  request->send(response);

}

void handleAqHistoryRequest(AsyncWebServerRequest* request) {

  JsonDocument doc;

  JsonArray aqHistoryJson = doc["aq_history"].to<JsonArray>();

  for(auto &e : aqHistory) {
    JsonObject jsonObj = aqHistoryJson.add<JsonObject>();
    jsonObj["time"] = e.time;
    jsonObj["temperature"] = e.temperature;
    jsonObj["humidity"] = e.humidity;
    jsonObj["pressure"] = e.pressure;
    jsonObj["pm25"] = e.pm25;
  }

  doc.shrinkToFit();

  AsyncResponseStream* response = request->beginResponseStream("application/json");

  serializeJson(doc, *response);
  request->send(response);

}

void initHttpServer() {

  httpServer.on("/sensor-data", HTTP_GET, handleSensorDataRequest);
  httpServer.on("/device", HTTP_GET, handleDeviceStatusRequest);

  httpServer.on("/aq-history", HTTP_GET, handleAqHistoryRequest);

  httpServer.begin();

}

void initMdns() {
  MDNS.begin(DEVICE_HOSTNAME);
  MDNS.addService(MDNS_SERVICE, "tcp", HTTP_SERVER_PORT);
}

void haltDevice() {
  while(true) {
    delay(1000);
  }
}
