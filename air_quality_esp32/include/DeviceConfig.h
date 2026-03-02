
#pragma once

#include <string>
#include <vector>

#define DEVICE_TYPE "air_quality"
#define DEVICE_VERSION "v0.2.0"

#define HTTP_SERVER_PORT 80

class WifiNetwork {

  public:

  std::string ssid;
  std::string password;

};

class DeviceConfig {
  
  public:

  std::string hostname;
  std::string deviceName;

  std::string deviceUuid;
  std::string backendAddress;

  /// @brief Recent data period in seconds
  uint32_t recentDataPeriod = 0;

  /// @brief History data period in seconds
  uint32_t historyDataPeriod = 0;

  std::vector<WifiNetwork> networks;

  bool parse(std::string configJson);
  std::string toJson();
  
};
