
#pragma once

#include <string>
#include <vector>

#define DEVICE_TYPE "air_quality"
#define DEVICE_VERSION "v1.0.0"

#define HTTP_SERVER_PORT 80

class WifiNetwork {
  public:

  std::string ssid;
  std::string password;
};

class AqmConfig {
  public:

  /// @brief Device UUID
  std::string deviceUuid;

  /// @brief Backend address
  std::string backendAddress;

  /// @brief Api key
  std::string apiKey;

  /// @brief Save air quality measurements or not
  bool saveMeasurements = false;

  /// @brief Send measurements and logs to the backend or not
  bool sendData = false;

  /// @brief Time period in seconds for saving measurements
  uint32_t measurementPeriod = 0;

};

class DeviceConfig {
  
  public:

  /// @brief mDNS device hostname
  std::string hostname;

  /// @brief Device name
  std::string deviceName;

  /// @brief Time period in seconds for saving measurements to recent data
  uint32_t recentDataPeriod = 0;

  /// @brief Config data for the AQM system
  AqmConfig aqmConfig;

  /// @brief List of wifi networks to connect
  std::vector<WifiNetwork> networks;

  bool parse(std::string configJson);
  std::string toJson();
  
};
