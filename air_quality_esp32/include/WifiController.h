
#pragma once

#include <Arduino.h>
#include <vector>

#include "DeviceController.h"

class WifiController {

  private:

  DeviceController* deviceController;

  public:
  
  WifiController(DeviceController* deviceController);

  void connect(std::vector<WifiNetwork>& networks);
  
  void initMdns();

  String getLocalIP();
  String getSSID();
  int getRSSI();

};
