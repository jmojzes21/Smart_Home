
#pragma once

#include <string>

class WifiNetwork {
    
    public:
    
    std::string ssid;
    std::string password;

    WifiNetwork(std::string& ssid, std::string& password) {
        this->ssid = ssid;
        this->password = password;
    }

};

class DiscoveredWifiNetwork {
    
    public:
    
    std::string ssid;
    int rssi;

    DiscoveredWifiNetwork(std::string& ssid, int rssi) {
        this->ssid = ssid;
        this->rssi = rssi;
    }

};
