
#include "DeviceConfig.h"
#include <ArduinoJson.h>

#define RECENT_DATA_MIN_PERIOD_SEC 30
#define RECENT_DATA_MAX_PERIOD_SEC 600

#define AQM_MEASUREMENTS_MIN_PERIOD_SEC 300
#define AQM_MEASUREMENTS_MAX_PERIOD_SEC 3600

#define CLAMP(x, min, max) (x > max ? max : (x < min ? min : x) )

bool DeviceConfig::parse(std::string configJson) {

  networks.clear();

  JsonDocument doc;

  auto error = deserializeJson(doc, configJson);
  if(error) {
    return false;
  }

  JsonObject aqm = doc["aqm"];

  hostname = doc["hostname"].as<std::string>();
  deviceName = doc["device_name"].as<std::string>();

  if(hostname.empty() || deviceName.empty()) {
    return false;
  }

  uint32_t recentPeriod = doc["recent_data_period"].as<uint32_t>();
  this->recentDataPeriod = CLAMP(recentPeriod, RECENT_DATA_MIN_PERIOD_SEC, RECENT_DATA_MAX_PERIOD_SEC);

  aqmDeviceUuid = aqm["device_uuid"].as<std::string>();
  aqmBackendAddress = aqm["backend_addr"].as<std::string>();

  uint32_t aqmPeriod = aqm["measurement_period"].as<uint32_t>();
  this->aqmMeasurementPeriod = CLAMP(aqmPeriod, AQM_MEASUREMENTS_MIN_PERIOD_SEC, AQM_MEASUREMENTS_MAX_PERIOD_SEC);

  aqmSaveMeasurements = aqm["save_measurements"].as<bool>();

  JsonArray networksJson = doc["wifi_networks"].as<JsonArray>();

  for(JsonObject e : networksJson) {
    WifiNetwork network;
    network.ssid = e["ssid"].as<std::string>();
    network.password = e["password"].as<std::string>();

    if(network.ssid.empty()) {
      continue;
    }

    networks.push_back(network);
  }

  return true;
}

std::string DeviceConfig::toJson() {

  JsonDocument doc;

  doc["hostname"] = hostname;
  doc["device_name"] = deviceName;
  doc["recent_data_period"] = recentDataPeriod;

  JsonObject aqm = doc["aqm"].to<JsonObject>();
  aqm["device_uuid"] = aqmDeviceUuid;
  aqm["backend_addr"] = aqmBackendAddress;
  aqm["measurement_period"] = aqmMeasurementPeriod;
  aqm["save_measurements"] = aqmSaveMeasurements;
  
  JsonArray networksJson = doc["wifi_networks"].to<JsonArray>();
  
  for(auto& net : networks) {
    JsonObject netJson = networksJson.add<JsonObject>();
    netJson["ssid"] = net.ssid;
    netJson["password"] = net.password;
  }

  std::string configJson = "";
  serializeJson(doc, configJson);
  
  return configJson;
}

