
#pragma once

#include <ArduinoJson.h>
#include <vector>
#include <LittleFS.h>

#include "wifi_net.h"

class Settings {

    private:

    bool _isLoaded = false;

    public:

    std::string deviceName;
    std::string devicePassword;

    int preferredWifiNetwork;
    std::vector<WifiNetwork> wifiNetworks;

    void load();
    void save();
    void reset();

    private:

    void _loadInitial();

};
