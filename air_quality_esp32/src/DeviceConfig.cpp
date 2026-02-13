
#include "DeviceConfig.h"
#include <ArduinoJson.h>

#define RECENT_HISTORY_MIN_PERIOD (30 * 1000)
#define RECENT_HISTORY_MAX_PERIOD (10 * 60 * 1000)

bool DeviceConfig::parse(std::string configJson) {

  networks.clear();

  JsonDocument doc;

  auto error = deserializeJson(doc, configJson);
  if(error) {
    return false;
  }

  hostname = doc["hostname"].as<std::string>();
  deviceName = doc["device_name"].as<std::string>();
  secretKey = doc["secret_key"].as<std::string>();

  if(hostname.empty() || deviceName.empty() || secretKey.empty()) {
    return false;
  }

  uint32_t recentPeriod = doc["recent_history_period"].as<uint32_t>();
  if(recentPeriod < RECENT_HISTORY_MIN_PERIOD) {
    recentPeriod = RECENT_HISTORY_MIN_PERIOD;
  }else if(recentPeriod > RECENT_HISTORY_MAX_PERIOD) {
    recentPeriod = RECENT_HISTORY_MAX_PERIOD;
  }

  this->recentHistoryPeriod = recentPeriod;

  JsonObject wifiJson = doc["wifi"].as<JsonObject>();
  JsonArray networksJson = wifiJson["networks"].as<JsonArray>();

  lastNetworkIndex = wifiJson["last"].as<int>();

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
  doc["secret_key"] = secretKey;

  doc["recent_history_period"] = recentHistoryPeriod;

  JsonObject wifiJson = doc["wifi"].to<JsonObject>();
  JsonArray networksJson = wifiJson["networks"].to<JsonArray>();

  wifiJson["last"] = lastNetworkIndex;

  for(auto& net : networks) {
    JsonObject netJson = networksJson.add<JsonObject>();
    netJson["ssid"] = net.ssid;
    netJson["password"] = net.password;
  }

  std::string configJson = "";
  serializeJson(doc, configJson);
  
  return configJson;
}

