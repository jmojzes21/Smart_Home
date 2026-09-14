
#pragma once

#include <Arduino.h>
#include <PCF85063A-SOLDERED.h>
#include <time.h>
#include <vector>

#include "DeviceConfig.h"
#include "helpers/DateTime.h"

class DeviceController {

  private:

  DeviceConfig config;

  PCF85063A rtc;
  SemaphoreHandle_t rtcMutex;

  DateTime bootTime;

  public:

  DeviceController();

  void init();

  DeviceConfig& getConfig();

  void readConfig();
  void saveConfig();

  std::string readConfigFile();
  void writeConfigFile(std::string& configJson);

  DateTime getDateTime();
  void setDateTime(DateTime t);

  DateTime getBootTime();

  void clearLed();
  void showColor(uint32_t color);
  void haltDevice();

  void restart(int delayMs);

};
