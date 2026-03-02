
#include "DeviceConfig.h"
#include <ArduinoJson.h>

#define RECENT_DATA_MIN_PERIOD_SEC (30)
#define RECENT_DATA_MAX_PERIOD_SEC (10 * 60)

#define HISTORY_DATA_MIN_PERIOD_SEC (5 * 60)
#define HISTORY_DATA_MAX_PERIOD_SEC (60 * 60)

bool DeviceConfig::parse(std::string configJson) {

  networks.clear();

  JsonDocument doc;

  auto error = deserializeJson(doc, configJson);
  if(error) {
    return false;
  }

  hostname = doc["hostname"].as<std::string>();
  deviceName = doc["device_name"].as<std::string>();
  deviceUuid = doc["device_uuid"].as<std::string>();
  backendAddress = doc["backend_addr"].as<std::string>();

  if(hostname.empty() || deviceName.empty()) {
    return false;
  }

  uint32_t recentPeriod = doc["recent_data_period"].as<uint32_t>();
  if(recentPeriod < RECENT_DATA_MIN_PERIOD_SEC) {
    recentPeriod = RECENT_DATA_MIN_PERIOD_SEC;
  }else if(recentPeriod > RECENT_DATA_MAX_PERIOD_SEC) {
    recentPeriod = RECENT_DATA_MAX_PERIOD_SEC;
  }

  uint32_t historyPeriod = doc["history_data_period"].as<uint32_t>();
  if(historyPeriod < HISTORY_DATA_MIN_PERIOD_SEC) {
    historyPeriod = HISTORY_DATA_MIN_PERIOD_SEC;
  }else if(historyPeriod > HISTORY_DATA_MAX_PERIOD_SEC) {
    historyPeriod = HISTORY_DATA_MAX_PERIOD_SEC;
  }

  this->recentDataPeriod = recentPeriod;
  this->historyDataPeriod = historyPeriod;

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
  doc["device_uuid"] = deviceUuid;
  doc["backend_addr"] = backendAddress;

  doc["recent_data_period"] = recentDataPeriod;
  doc["history_data_period"] = historyDataPeriod;

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

