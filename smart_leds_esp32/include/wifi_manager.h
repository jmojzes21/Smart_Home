
#pragma once

#include <Arduino.h>
#include <WiFi.h>
#include <vector>

#include "settings.h"
#include "wifi_net.h"

#include "device.h"

static const int wifiConnectTimeout = 4000;

class WifiManager {

    private:

    Device* _device = nullptr;

    public:

    void setup(Device* device) {
        _device = device;
    }

    void connectToWifi(std::vector<WifiNetwork>& networks, int preferred) {

        // ako nema wifi mreža,
        // otvori wifi pristupnu točku
        if(networks.size() == 0) {
            _startAccessPoint();
            return;
        }

        // ako imamo poželjnu mrežu
        // pokušajmo se povezati na nju
        if(preferred >= 0 && preferred < networks.size()) {
            WifiNetwork& network = networks[preferred];
            bool success = _connectToNetwork(network);

            if(success) {
                // uspjeli smo se povezati na poželjnu mrežu
                return;
            }
        }

        // nema poželjne mreže ili se nismo
        // uspjeli povezati na nju
        
        // pretraži dostupne wifi mreže

        WiFi.mode(WIFI_STA);
        WiFi.disconnect();

        int n = WiFi.scanNetworks();
        std::vector<DiscoveredWifiNetwork> availableNetworks;

        for(int i = 0; i < n; i++) {
            availableNetworks.emplace_back(WiFi.SSID(i), WiFi.RSSI(i));
        }

        WiFi.scanDelete();




    }

    private:

    bool _connectToNetwork(WifiNetwork& network) {

        WiFi.disconnect();
        WiFi.begin(network.ssid.c_str(), network.password.c_str());

        uint32_t start = millis();
        while(WiFi.status() != WL_CONNECTED) {

            uint32_t now = millis();
            if(now - start > wifiConnectTimeout) {
                // nismo se uspjeli povezati na wifi mrežu
                // unutar određenog perioda
                return false;
            }

            delay(100);
        }

        // povezali smo se na wifi mrežu
        return true;
    }

    void _startAccessPoint() {
        WiFi.disconnect();
        WiFi.softAP(_device->name.c_str());
    }

    int _findBestNetwork(std::vector<DiscoveredWifiNetwork>& availableNetworks, std::vector<WifiNetwork>& networks, int preferred) {

        std::sort(availableNetworks.begin(), availableNetworks.end(), [](DiscoveredWifiNetwork& a, DiscoveredWifiNetwork& b) {
            
        });

        // NASTAVI
        WiFi.SSID(4);
        WiFi.RSSI(0);

        return 0;
    }

};
