
#pragma once

#include <ArduinoJson.h>
#include <LittleFS.h>
#include <vector>

#include "wifi_net.h"

const char* _settingsPath = "/settings";

class Settings {

    public:

    std::string deviceName;
    std::string devicePassword;

    int preferredWifiNetwork;
    std::vector<WifiNetwork> wifiNetworks;

    void open() {

        LittleFS.begin(true);

        if(LittleFS.exists(_settingsPath) == false) {
            _loadInitialSettings();
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

    }

    void save() {

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

    void close() {
        LittleFS.end();
    }

    private:

    void _loadInitialSettings() {
        deviceName = "Smart LEDs";
        devicePassword = "admin";
        
        preferredWifiNetwork = 0;
        wifiNetworks.clear();
    }

};
