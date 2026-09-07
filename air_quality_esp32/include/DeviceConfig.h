
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

class DeviceConfig {
  
  public:

  /// @brief mDNS device hostname
  std::string hostname;

  /// @brief Device name
  std::string deviceName;

  /// @brief Time period in seconds for saving measurements to recent data
  uint32_t recentDataPeriod = 0;

  /// @brief AQM device UUID
  std::string aqmDeviceUuid;

  /// @brief AQM backend address
  std::string aqmBackendAddress;

  /// @brief Time period in seconds for saving measurements to the AQM system
  uint32_t aqmMeasurementPeriod = 0;

  /// @brief Save measurements to the AQM system or not
  bool aqmSaveMeasurements = false;

  /// @brief List of wifi networks to connect
  std::vector<WifiNetwork> networks;

  bool parse(std::string configJson);
  std::string toJson();
  
};
