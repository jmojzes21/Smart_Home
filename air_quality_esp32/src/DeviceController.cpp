
#include "DeviceController.h"

#include <ArduinoJson.h>
#include <LittleFS.h>
#include <DasduinoLed.h>

#define CONFIG_FILE_PATH "/config.json"

DeviceController::DeviceController() {

}

void DeviceController::init() {

  rtcMutex = xSemaphoreCreateMutex();

  rtc.begin();
  bootTime = getDateTime();

  DasduinoLed::init();
  DasduinoLed::setBrightness(20);

  LittleFS.begin(true);
  readConfig();
  
}

DeviceConfig& DeviceController::getConfig() {
  return config;
}


void DeviceController::readConfig() {

  auto configJson = readConfigFile();
  log_i("Config: %s", configJson.c_str());

  config.parse(configJson);

}

void DeviceController::saveConfig() {

  auto configJson = config.toJson();
  log_i("Config: %s", configJson.c_str());

  writeConfigFile(configJson);
  
}

std::string DeviceController::readConfigFile() {

  File file = LittleFS.open(CONFIG_FILE_PATH, FILE_READ);

  if(!file) {
    showColor(LedColors::Orange);
    haltDevice();
  }

  std::string configJson(file.size(), ' ');
  file.readBytes((char*)configJson.data(), configJson.length());
  file.close();

  return configJson;
}

void DeviceController::writeConfigFile(std::string& configJson) {
  
  File file = LittleFS.open(CONFIG_FILE_PATH, FILE_WRITE);

  if(!file) {
    showColor(LedColors::Orange);
    haltDevice();
  }

  file.write((uint8_t*)configJson.data(), configJson.size());
  file.close();

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