
#include "DeviceController.h"

#include <ArduinoJson.h>
#include <LittleFS.h>
#include <DasduinoLed.h>

#define WIFI_FILE_PATH "/wifi.json"

DeviceController::DeviceController() {

}

void DeviceController::init() {

  rtcMutex = xSemaphoreCreateMutex();

  rtc.begin();
  bootTime = getDateTime();

  DasduinoLed::init();
  DasduinoLed::setBrightness(20);

  LittleFS.begin(true);
  
}

struct tm DeviceController::getDateTime() {

  xSemaphoreTake(rtcMutex, portMAX_DELAY);

  rtc.readTime();

  tm t;
  t.tm_mday = rtc.getDay();
  t.tm_mon = rtc.getMonth();
  t.tm_year = rtc.getYear();
  t.tm_hour = rtc.getHour();
  t.tm_min = rtc.getMinute();
  t.tm_sec = rtc.getSecond();

  xSemaphoreGive(rtcMutex);

  return t;
}

void DeviceController::setDateTime(struct tm t) {

  xSemaphoreTake(rtcMutex, portMAX_DELAY);

  rtc.setDate(t.tm_wday, t.tm_mday, t.tm_mon, t.tm_year);
  rtc.setTime(t.tm_hour, t.tm_min, t.tm_sec);

  xSemaphoreGive(rtcMutex);

}

tm DeviceController::getBootTime() {
  return bootTime;
}

void DeviceController::getWifiNetworks(std::vector<WifiNetwork> &networks) {

  File file = LittleFS.open(WIFI_FILE_PATH, FILE_READ);

  if(!file) {
    showColor(LedColors::Orange);
    haltDevice();
  }

  JsonDocument doc;
  deserializeJson(doc, file);
  file.close();

  WifiNetwork network;
  network.ssid = doc["ssid"].as<std::string>();
  network.password = doc["password"].as<std::string>();

  networks.push_back(network);
  
}

void DeviceController::clearLed() {
  DasduinoLed::clear();
}

void DeviceController::showColor(uint32_t color) {
  DasduinoLed::showColor(color);
}

void DeviceController::haltDevice() {
  while(true) {
    delay(1000);
  }
}