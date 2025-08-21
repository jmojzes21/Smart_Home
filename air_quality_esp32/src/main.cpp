
#include <Arduino.h>
#include <WiFi.h>
#include <ESPAsyncWebServer.h>
#include <ESPmDNS.h>
#include <Adafruit_BME280.h>
#include <SHTC3-SOLDERED.h>
#include <ArduinoJson.h>
#include <LittleFS.h>

#include "dasduino_led.h"

#define DEVICE_HOSTNAME "meteo_sensor"
#define HTTP_SERVER_PORT 80

#define WIFI_CONNECT_TIMEOUT 5000

Adafruit_BME280 bme280Sensor;
SHTC3 shtc3Sensor;
SemaphoreHandle_t sensorMutex;

AsyncWebServer httpServer(HTTP_SERVER_PORT);
DasduinoLed dasduinoLed;

void connectWifi();
void initHttpServer();
void initMdns();
void haltDevice();

void readSensorData(float& temperature, float& humidity);
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

  sensorMutex = xSemaphoreCreateMutex();

  connectWifi();
  initHttpServer();
  initMdns();

}

void loop() {
  delay(1000);
}

void readSensorData(JsonDocument& document) {
  
  xSemaphoreTake(sensorMutex, portMAX_DELAY);

  JsonObject bme280 = document["bme280"].to<JsonObject>();
  JsonObject shtc3 = document["shtc3"].to<JsonObject>();

  bme280["temperature"] = (float)bme280Sensor.readTemperature();
  bme280["humidity"] = (float)bme280Sensor.readHumidity();
  bme280["pressure"] = (float)(bme280Sensor.readPressure() / 100.0f);

  shtc3Sensor.sample();
  shtc3["temperature"] = (float)shtc3Sensor.readTempC();
  shtc3["humidity"] = (float)shtc3Sensor.readHumidity();

  xSemaphoreGive(sensorMutex);

}

void handleSensorDataRequest(AsyncWebServerRequest* request) {

  JsonDocument document;
  readSensorData(document);

  AsyncResponseStream* response = request->beginResponseStream("application/json");

  serializeJson(document, *response);
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
  httpServer.on("/", HTTP_GET, handleSensorDataRequest);
  httpServer.begin();
}

void initMdns() {
  MDNS.begin(DEVICE_HOSTNAME);
  MDNS.addService("http", "tcp", HTTP_SERVER_PORT);
}

void haltDevice() {
  while(true) {
    delay(1000);
  }
}
