
#pragma once

#include <string>

#define DEVICE_HOSTNAME "air-quality-sensor"
#define DEVICE_DOMAIN "air-quality-sensor.local"
#define DEVICE_NAME "Kvaliteta zraka"
#define DEVICE_TYPE "air_quality"
#define DEVICE_VERSION "v0.2.0"

#define HTTP_SERVER_PORT 80
#define MDNS_SERVICE "smart-home"

struct DeviceConfig {
  std::string hostname;
};

struct WifiNetwork {
  std::string ssid;
  std::string password;
};
