
#include "DeviceController.h"

#include <ArduinoJson.h>
#include <LittleFS.h>
#include <DasduinoLed.h>

#define CONFIG_FILE_PATH "/config.json"

DeviceController::DeviceController() {

}

static void setEspDateTime(DateTime dt) {
  struct tm t = {0};
  t.tm_wday = dt.weekday;
  t.tm_mday = dt.day;
  t.tm_mon = dt.month - 1;
  t.tm_year = dt.year - 1900;

  t.tm_hour = dt.hour;
  t.tm_min = dt.minute;
  t.tm_sec = dt.second;

  time_t epoch = mktime(&t);

  struct timeval tv;
  tv.tv_sec = epoch;
  tv.tv_usec = 0;

  settimeofday(&tv, NULL);

}

void DeviceController::init() {

  // init rtc
  rtcMutex = xSemaphoreCreateMutex();
  rtc.begin();

  // get boot time
  bootTime = getDateTime();

  // init rgb led
  DasduinoLed::init();
  DasduinoLed::setBrightness(20);

  // read config
  readConfig();
  
  // init esp time
  DateTime now = getDateTime();
  setEspDateTime(now);

}

DeviceConfig& DeviceController::getConfig() {
  return config;
}

AqmConfig& DeviceController::getAqmConfig() {
  return config.aqmConfig;
}

void DeviceController::readConfig() {
  auto configJson = readConfigFile();
  if(!config.parse(configJson)) {
    log_e("Bad config");
    showColor(LedColors::Orange);
    haltDevice();
  }
}

void DeviceController::saveConfig() {
  auto configJson = config.toJson();
  writeConfigFile(configJson);
}

std::string DeviceController::readConfigFile() {

  File file = LittleFS.open(CONFIG_FILE_PATH, FILE_READ);

  if(!file) {
    log_e("Can't read config file %s", CONFIG_FILE_PATH);
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
    log_e("Can't write config file %s", CONFIG_FILE_PATH);
    showColor(LedColors::Orange);
    haltDevice();
  }

  file.write((uint8_t*)configJson.data(), configJson.size());
  file.close();

}

DateTime DeviceController::getDateTime() {

  xSemaphoreTake(rtcMutex, portMAX_DELAY);

  rtc.readTime();

  DateTime t;
  t.setDate(rtc.getWeekday(), rtc.getDay(), rtc.getMonth(), rtc.getYear());
  t.setTime(rtc.getHour(), rtc.getMinute(), rtc.getSecond());

  xSemaphoreGive(rtcMutex);

  return t;
}

void DeviceController::setDateTime(DateTime t) {

  xSemaphoreTake(rtcMutex, portMAX_DELAY);

  rtc.setDate(t.weekday, t.day, t.month, t.year);
  rtc.setTime(t.hour, t.minute, t.second);

  xSemaphoreGive(rtcMutex);

}

DateTime DeviceController::getBootTime() {
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

void deviceRestartTask(void* param) {

  int delayMs = *(int*)param;
  delay(delayMs);

  ESP.restart();

}

void DeviceController::restart(int delayMs) {

  int* param = new int;
  *param = delayMs;

  TaskHandle_t restartTaskHandle;
  xTaskCreateUniversal(deviceRestartTask, "restartTask", 4096, param, 1, &restartTaskHandle, ARDUINO_RUNNING_CORE);
  
}
