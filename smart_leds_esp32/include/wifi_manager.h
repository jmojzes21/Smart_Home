
#pragma once

#include <WiFi.h>

#include "settings.h"
#include "device.h"

class WifiManager {

    public:

    void setup();

    void connectToWifi();

    private:

    bool _connectToNetwork(WifiNetwork& network);
    int _findBestNetwork(std::vector<WifiNetwork>& networks);

    void _startAccessPoint();
    
};
