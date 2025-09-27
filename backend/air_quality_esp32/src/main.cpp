
#include <Arduino.h>
#include <WiFi.h>
#include <ESPAsyncWebServer.h>
#include <ESPmDNS.h>
#include <Adafruit_BME280.h>
#include <SHTC3-SOLDERED.h>
#include <ArduinoJson.h>
#include <LittleFS.h>

#include "dasduino_led.h"
#include "PMS5003.h"

#define DEVICE_HOSTNAME "air-quality-sensor"
#define DEVICE_DOMAIN "air-quality-sensor._smart-home._tcp.local"
#define DEVICE_NAME "Kvaliteta zraka"
#define DEVICE_TYPE "air_quality"
#define DEVICE_VERSION "v0.1.0"

#define MDNS_SERVICE "smart-home"
#define HTTP_SERVER_PORT 80

#define WIFI_CONNECT_TIMEOUT 5000

#define PMS_RX_PIN 14
#define PMS_TX_PIN 15

Adafruit_BME280 bme280Sensor;
SHTC3 shtc3Sensor;
SemaphoreHandle_t sensorMutex;

AsyncWebServer httpServer(HTTP_SERVER_PORT);
DasduinoLed dasduinoLed;

PMS5003_Sensor pms5003Sensor;
PMS5003_Data pmsData;
SemaphoreHandle_t pmsMutex;

void connectWifi();
void initHttpServer();
void initMdns();
void haltDevice();

void handleSensorDataRequest(AsyncWebServerRequest* request);

void setup() {

  Serial.begin(115200);

  dasduinoLed.begin();
  dasduinoLed.setBrightness(20);

  Wire.begin();

  if(!bme280Sensor.begin(BME280_ADDRESS_ALTERNATE)) {
    dasduinoLed.showColor(CRGB::Orange);
    haltDevice();
  }

  if(!shtc3Sensor.begin()) {
    dasduinoLed.showColor(CRGB::Orange);
    haltDevice();
  }

  pms5003Sensor.init(&Serial2, PMS_RX_PIN, PMS_TX_PIN);

  sensorMutex = xSemaphoreCreateMutex();
  pmsMutex = xSemaphoreCreateMutex();

  connectWifi();
  initHttpServer();
  initMdns();

  delay(200);

}

void loop() {

  PMS5003_Data tdata;
  if(pms5003Sensor.read(&tdata)) {
    xSemaphoreTake(pmsMutex, portMAX_DELAY);
    pmsData = tdata;
    xSemaphoreGive(pmsMutex);
  }

  delay(2000);
}

void readSensorData(JsonDocument& document) {
  
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

  pms["pm1.0"] = pmsData.pm_10_env;
  pms["pm2.5"] = pmsData.pm_25_env;
  pms["pm10"] = pmsData.pm_100_env;

  pms["p0.3"] = pmsData.particles_03;
  pms["p0.5"] = pmsData.particles_05;
  pms["p1.0"] = pmsData.particles_10;
  pms["p2.5"] = pmsData.particles_25;
  pms["p5.0"] = pmsData.particles_50;
  pms["p10"] = pmsData.particles_100;
  
  xSemaphoreGive(pmsMutex);

}

void handleSensorDataRequest(AsyncWebServerRequest* request) {

  JsonDocument document;
  readSensorData(document);

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

  AsyncResponseStream* response = request->beginResponseStream("application/json");

  serializeJson(doc, *response);
  request->send(response);

}

void connectWifi() {

  JsonDocument document;

  LittleFS.begin(true);

  File file = LittleFS.open("/wifi.json", FILE_READ);

  if(!file) {
    dasduinoLed.showColor(CRGB::Orange);
    haltDevice();
  }

  deserializeJson(document, file);
  file.close();

  LittleFS.end();

  String ssid = document["ssid"];
  String password = document["password"];

  dasduinoLed.showColor(CRGB::Blue);

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
    dasduinoLed.showColor(CRGB::Orange);
    haltDevice();
  }

  dasduinoLed.turnOff();

}

void initHttpServer() {

  httpServer.on("/sensor-data", HTTP_GET, handleSensorDataRequest);
  httpServer.on("/status", HTTP_GET, handleDeviceStatusRequest);

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
