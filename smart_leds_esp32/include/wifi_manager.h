
#pragma once

#include <WiFi.h>

#include "settings.h"
#include "device.h"

class WifiManager {

    private:

    Device* _device = nullptr;

    public:

    void setup(Device* device);

    void connectToWifi();

    private:

    bool _connectToNetwork(WifiNetwork& network);
    int _findBestNetwork(std::vector<WifiNetwork>& networks);

    void _startAccessPoint();
    
};
