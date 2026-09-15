
#include "DeviceConfig.h"
#include <ArduinoJson.h>

#define RECENT_DATA_MIN_PERIOD_SEC 30
#define RECENT_DATA_MAX_PERIOD_SEC 600

#define AQM_MEASUREMENTS_MIN_PERIOD_SEC 300
#define AQM_MEASUREMENTS_MAX_PERIOD_SEC 3600

#define JSON_HOSTNAME "hostname"
#define JSON_DEVICE_NAME "device_name"
#define JSON_RECENT_PERIOD "recent_data_period"
#define JSON_WIFI_NETWORKS "wifi_networks"
#define JSON_WIFI_SSID "ssid"
#define JSON_WIFI_PASSWORD "password"

#define JSON_AQM "aqm"
#define JSON_AQM_DEVICE_UUID "device_uuid"
#define JSON_AQM_BACKEND_ADDR "backend_addr"
#define JSON_AQM_API_KEY "api_key"
#define JSON_AQM_SAVE_MEASUREMENTS "save_measurements"
#define JSON_AQM_SEND_DATA "send_data"
#define JSON_AQM_MEASUREMENT_PERIOD "measurement_period"

#define CLAMP(x, min, max) (x > max ? max : (x < min ? min : x) )

bool DeviceConfig::parse(std::string configJson) {

  networks.clear();

  JsonDocument doc;

  auto error = deserializeJson(doc, configJson);
  if(error) {
    return false;
  }

  JsonObject aqm = doc[JSON_AQM];

  hostname = doc[JSON_HOSTNAME].as<std::string>();
  deviceName = doc[JSON_DEVICE_NAME].as<std::string>();

  if(hostname.empty() || deviceName.empty()) {
    return false;
  }

  uint32_t recentPeriod = doc[JSON_RECENT_PERIOD].as<uint32_t>();
  this->recentDataPeriod = CLAMP(recentPeriod, RECENT_DATA_MIN_PERIOD_SEC, RECENT_DATA_MAX_PERIOD_SEC);

  aqmConfig.deviceUuid = aqm[JSON_AQM_DEVICE_UUID].as<std::string>();
  aqmConfig.backendAddress = aqm[JSON_AQM_BACKEND_ADDR].as<std::string>();
  aqmConfig.apiKey = aqm[JSON_AQM_API_KEY].as<std::string>();

  aqmConfig.saveMeasurements = aqm[JSON_AQM_SAVE_MEASUREMENTS].as<bool>();
  aqmConfig.sendData = aqm[JSON_AQM_SEND_DATA].as<bool>();

  uint32_t aqmPeriod = aqm[JSON_AQM_MEASUREMENT_PERIOD].as<uint32_t>();
  aqmConfig.measurementPeriod = CLAMP(aqmPeriod, AQM_MEASUREMENTS_MIN_PERIOD_SEC, AQM_MEASUREMENTS_MAX_PERIOD_SEC);

  JsonArray networksJson = doc[JSON_WIFI_NETWORKS].as<JsonArray>();

  for(JsonObject e : networksJson) {
    WifiNetwork network;
    network.ssid = e[JSON_WIFI_SSID].as<std::string>();
    network.password = e[JSON_WIFI_PASSWORD].as<std::string>();

    if(network.ssid.empty()) {
      continue;
    }

    networks.push_back(network);
  }

  return true;
}

std::string DeviceConfig::toJson() {

  JsonDocument doc;

  doc[JSON_HOSTNAME] = hostname;
  doc[JSON_DEVICE_NAME] = deviceName;
  doc[JSON_RECENT_PERIOD] = recentDataPeriod;

  JsonObject aqm = doc[JSON_AQM].to<JsonObject>();
  aqm[JSON_AQM_DEVICE_UUID] = aqmConfig.deviceUuid;
  aqm[JSON_AQM_BACKEND_ADDR] = aqmConfig.backendAddress;
  aqm[JSON_AQM_API_KEY] = aqmConfig.apiKey;
  aqm[JSON_AQM_SAVE_MEASUREMENTS] = aqmConfig.saveMeasurements;
  aqm[JSON_AQM_SEND_DATA] = aqmConfig.sendData;
  aqm[JSON_AQM_MEASUREMENT_PERIOD] = aqmConfig.measurementPeriod;
  
  JsonArray networksJson = doc[JSON_WIFI_NETWORKS].to<JsonArray>();
  
  for(auto& net : networks) {
    JsonObject netJson = networksJson.add<JsonObject>();
    netJson[JSON_WIFI_SSID] = net.ssid;
    netJson[JSON_WIFI_PASSWORD] = net.password;
  }

  std::string configJson = "";
  serializeJson(doc, configJson);
  
  return configJson;
}

