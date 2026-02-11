
#include "DeviceConfig.h"
#include <ArduinoJson.h>

#define RECENT_HISTORY_MIN_PERIOD (30 * 1000)
#define RECENT_HISTORY_MAX_PERIOD (10 * 60 * 1000)

void DeviceConfig::parse(std::string configJson) {

  networks.clear();

  JsonDocument doc;
  deserializeJson(doc, configJson);

  this->hostname = doc["hostname"].as<std::string>();
  this->deviceName = doc["device_name"].as<std::string>();

  uint32_t recentPeriod = doc["recent_history_period"].as<uint32_t>();
  if(recentPeriod < RECENT_HISTORY_MIN_PERIOD) {
    recentPeriod = RECENT_HISTORY_MIN_PERIOD;
  }else if(recentPeriod > RECENT_HISTORY_MAX_PERIOD) {
    recentPeriod = RECENT_HISTORY_MAX_PERIOD;
  }

  this->recentHistoryPeriod = recentPeriod;

  JsonObject wifiJson = doc["wifi"].as<JsonObject>();
  JsonArray networksJson = wifiJson["networks"].as<JsonArray>();

  this->lastNetworkIndex = wifiJson["last"].as<int>();

  for(JsonObject e : networksJson) {
    WifiNetwork network;
    network.ssid = e["ssid"].as<std::string>();
    network.password = e["password"].as<std::string>();

    this->networks.push_back(network);
  }

}

std::string DeviceConfig::toJson() {

  JsonDocument doc;

  doc["hostname"] = this->hostname;
  doc["device_name"] = this->deviceName;

  doc["recent_history_period"] = this->recentHistoryPeriod;

  JsonObject wifiJson = doc["wifi"].to<JsonObject>();
  JsonArray networksJson = wifiJson["networks"].to<JsonArray>();

  wifiJson["last"] = this->lastNetworkIndex;

  for(auto& net : this->networks) {
    JsonObject netJson = networksJson.add<JsonObject>();
    netJson["ssid"] = net.ssid;
    netJson["password"] = net.password;
  }

  std::string configJson = "";
  serializeJson(doc, configJson);
  
  return configJson;
}

