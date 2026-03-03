
#include "settings.h"

static const char* _settingsPath = "/settings.json";

void Settings::load() {

    Serial.printf("Učitaj postavke\n");

    if(LittleFS.exists(_settingsPath) == false) {

        Serial.printf("Datoteka postavki ne postoji\n");
        Serial.printf("Stvori zadane postavke\n");

        _loadInitial();
        save();
        return;
    }

    JsonDocument document;

    File file = LittleFS.open(_settingsPath, FILE_READ);
    deserializeJson(document, file);
    file.close();

    JsonObject device = document["device"];

    deviceName = device["name"].as<std::string>();
    devicePassword = device["password"].as<std::string>();
    deviceUuid = device["uuid"].as<std::string>();

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

    Serial.printf("Spremi postavke\n");

    JsonDocument document;

    JsonObject device = document["device"].to<JsonObject>();

    device["name"] = deviceName;
    device["password"] = devicePassword;
    device["uuid"] = deviceUuid;

    JsonObject wifi = document["wifi"].to<JsonObject>();
    wifi["preferred"] = preferredWifiNetwork;

    JsonArray networks = wifi["networks"].to<JsonArray>();
    for(int i = 0; i < wifiNetworks.size(); i++) {

        JsonObject net = networks[i].to<JsonObject>();
        WifiNetwork& wnet = wifiNetworks[i];

        net["ssid"] = wnet.ssid;
        net["pass"] = wnet.password;
    }

    File file = LittleFS.open(_settingsPath, FILE_WRITE);
    serializeJson(document, file);
    file.close();

}

void Settings::reset() {
    _loadInitial();
    save();
}

void Settings::_loadInitial() {

    _isLoaded = true;

    deviceName = "Pametne LEDice";

    // lozinka: "pass"
    devicePassword = "10/w7o2juYBrGMh32/KbveULW9jk2tejpyUAD+uC6PE=";
    
    preferredWifiNetwork = -1;
    wifiNetworks.clear();
}
