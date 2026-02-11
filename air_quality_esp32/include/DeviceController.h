
#pragma once

#include <Arduino.h>
#include <PCF85063A-SOLDERED.h>
#include <time.h>
#include <vector>

#include "DeviceConfig.h"

class DeviceController {

  private:

  DeviceConfig config;

  PCF85063A rtc;
  SemaphoreHandle_t rtcMutex;

  struct tm bootTime;

  public:

  DeviceController();

  void init();

  DeviceConfig& getConfig();

  void readConfig();
  void saveConfig();

  std::string readConfigFile();
  void writeConfigFile(std::string& configJson);

  struct tm getDateTime();
  void setDateTime(struct tm t);

  struct tm getBootTime();

  void clearLed();
  void showColor(uint32_t color);
  void haltDevice();

};
