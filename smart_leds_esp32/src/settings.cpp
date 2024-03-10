
#include "settings.h"

static const char* _settingsPath = "/settings";

void Settings::load() {

    if(LittleFS.exists(_settingsPath) == false) {
        _loadInitial();
        save();
        _isLoaded = true;
        return;
    }

    JsonDocument document;

    File file = LittleFS.open(_settingsPath, FILE_READ);
    deserializeJson(document, file);
    file.close();

    JsonObject device = document["device"];

    deviceName = device["name"].as<std::string>();
    devicePassword = device["password"].as<std::string>();

    JsonObject wifi = document["wifi"];
    preferredWifiNetwork = wifi["preferred"].as<int>();

    JsonArray networks = wifi["networks"];
    wifiNetworks.clear();

    for(int i = 0; i < networks.size(); i++) {
        JsonObject net = networks[i];

        std::string ssid = net["ssid"];
        std::string pass = net["pass"];

        wifiNetworks.emplace_back(ssid, pass);
    }

    _isLoaded = true;

}

void Settings::save() {

    if(_isLoaded == false) return;

    JsonDocument document;

    JsonObject device = document["device"].as<JsonObject>();

    device["name"] = deviceName;
    device["password"] = devicePassword;

    JsonObject wifi = document["wifi"].as<JsonObject>();
    wifi["preferred"] = preferredWifiNetwork;

    JsonArray networks = wifi["networks"].as<JsonArray>();
    for(int i = 0; i < wifiNetworks.size(); i++) {

        JsonObject net = networks[i].as<JsonObject>();
        WifiNetwork& wnet = wifiNetworks[i];

        net["ssid"] = wnet.ssid;
        net["pass"] = wnet.password;
    }

    File file = LittleFS.open(_settingsPath, FILE_WRITE);
    serializeJson(document, file);
    file.close();

}

void Settings::_loadInitial() {
    deviceName = "Smart LEDs";
    devicePassword = "admin";
    
    preferredWifiNetwork = -1;
    wifiNetworks.clear();
}
