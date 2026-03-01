
#include "DeviceConfig.h"
#include <ArduinoJson.h>

#define RECENT_HISTORY_MIN_PERIOD_SEC (30)
#define RECENT_HISTORY_MAX_PERIOD_SEC (10 * 60)

bool DeviceConfig::parse(std::string configJson) {

  networks.clear();

  JsonDocument doc;

  auto error = deserializeJson(doc, configJson);
  if(error) {
    return false;
  }

  hostname = doc["hostname"].as<std::string>();
  deviceName = doc["device_name"].as<std::string>();

  if(hostname.empty() || deviceName.empty()) {
    return false;
  }

  uint32_t recentPeriod = doc["recent_history_period"].as<uint32_t>();
  if(recentPeriod < RECENT_HISTORY_MIN_PERIOD_SEC) {
    recentPeriod = RECENT_HISTORY_MIN_PERIOD_SEC;
  }else if(recentPeriod > RECENT_HISTORY_MAX_PERIOD_SEC) {
    recentPeriod = RECENT_HISTORY_MAX_PERIOD_SEC;
  }

  this->recentHistoryPeriod = recentPeriod;

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

  doc["recent_history_period"] = recentHistoryPeriod;

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

