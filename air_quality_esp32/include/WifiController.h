
#pragma once

#include <Arduino.h>
#include <vector>

#include "DeviceController.h"

class WifiController {

  private:

  DeviceController* deviceController;

  public:
  
  WifiController(DeviceController* deviceController);

  void connect();
  
  void initMdns();

  String getLocalIP();
  String getSSID();
  int getRSSI();

  private:

  int findBestNetwork(std::vector<WifiNetwork>& networks);
  bool connectToNetwork(WifiNetwork& network);
  void startAccessPoint();

};
