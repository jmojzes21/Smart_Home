
#include <Arduino.h>
#include <WiFi.h>
#include <ESPAsyncWebServer.h>
#include <ESPmDNS.h>
#include <SHTC3-SOLDERED.h>
#include <ArduinoJson.h>
#include <LittleFS.h>

#include "dasduino_led.h"

#define DEVICE_HOSTNAME "shtc3_sensor"
#define HTTP_SERVER_PORT 80

#define WIFI_CONNECT_TIMEOUT 4000

SHTC3 shtc3Sensor;
SemaphoreHandle_t shtc3SensorMutex;

AsyncWebServer httpServer(HTTP_SERVER_PORT);
DasduinoLed dasduinoLed;

void connectWifi();
void initHttpServer();
void initMdns();
void haltDevice();

void readSensorData(float& temperature, float& humidity);
void handleSensorDataRequest(AsyncWebServerRequest* request);

void setup() {

  dasduinoLed.begin();
  dasduinoLed.setBrightness(20);

  shtc3Sensor.begin();
  shtc3SensorMutex = xSemaphoreCreateMutex();

  connectWifi();
  initHttpServer();
  initMdns();

}

void loop() {
  delay(1000);
}

void readSensorData(float& temperature, float& humidity) {
  
  xSemaphoreTake(shtc3SensorMutex, portMAX_DELAY);

  shtc3Sensor.sample();

  temperature = shtc3Sensor.readTempC();
  humidity = shtc3Sensor.readHumidity();

  xSemaphoreGive(shtc3SensorMutex);

}

void handleSensorDataRequest(AsyncWebServerRequest* request) {

  float temperature = 0;
  float humidity = 0;

  readSensorData(temperature, humidity);

  AsyncResponseStream* response = request->beginResponseStream("application/json");

  JsonDocument document;
  document["temperature"] = temperature;
  document["humidity"] = humidity;

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
