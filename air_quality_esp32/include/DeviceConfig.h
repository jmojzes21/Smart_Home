
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
  std::string secretKey;

  /// @brief Recent history period in seconds
  uint32_t recentHistoryPeriod = 0;

  /// @brief Index of last connected wifi network
  int lastNetworkIndex = 0;
  std::vector<WifiNetwork> networks;

  bool parse(std::string configJson);
  std::string toJson();
  
};
