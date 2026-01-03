
#pragma once

#include <Arduino.h>
#include <PCF85063A-SOLDERED.h>
#include <time.h>
#include <vector>

#include "DeviceConfig.h"

class DeviceController {

  private:

  PCF85063A rtc;
  SemaphoreHandle_t rtcMutex;

  public:

  DeviceController();

  void init();

  struct tm getDateTime();
  void setDateTime(struct tm t);

  void getWifiNetworks(std::vector<WifiNetwork>& networks);

  void clearLed();
  void showColor(uint32_t color);
  void haltDevice();

};
