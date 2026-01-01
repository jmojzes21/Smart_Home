
#pragma once

#include <Arduino.h>
#include <vector>

#include "DeviceConfig.h"

class DeviceController {

  private:

  public:

  DeviceController();

  void init();

  void getWifiNetworks(std::vector<WifiNetwork>& networks);

  void clearLed();
  void showColor(uint32_t color);
  void haltDevice();

};
