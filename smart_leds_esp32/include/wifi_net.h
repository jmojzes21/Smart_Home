
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
