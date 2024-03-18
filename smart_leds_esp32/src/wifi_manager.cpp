
#include "wifi_manager.h"

static const int wifiConnectTimeout = 4000;

extern Device device;

void WifiManager::setup() {}

void WifiManager::connectToWifi() {

    Settings settings;
    settings.load();

    auto& networks = settings.wifiNetworks;
    int preferred = settings.preferredWifiNetwork;

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
    
    // pretraži dostupne wifi mreže i
    // poveži se na najbolju

    int best = _findBestNetwork(networks);

    if(best == -1 || best == preferred) {
        // nema dostupnih wifi mreža na koje se možemo povezati
        _startAccessPoint();
        return;
    }

    // poveži se na najbolju mrežu

    WifiNetwork& bestNetwork = networks[best];
    bool success = _connectToNetwork(bestNetwork);

    if(success) {
        // postavi najbolju mrežu kao preferiranu
        settings.preferredWifiNetwork = best;
        settings.save();
    }else{
        _startAccessPoint();
    }

}

bool WifiManager::_connectToNetwork(WifiNetwork& network) {

    WiFi.disconnect();
    WiFi.mode(WIFI_STA);
    WiFi.begin(network.ssid.c_str(), network.password.c_str());

    uint32_t start = millis();
    while(WiFi.status() != WL_CONNECTED) {

        uint32_t now = millis();
        if(now - start > wifiConnectTimeout) {
            // nismo se uspjeli povezati na wifi mrežu
            // unutar određenog perioda
            return false;
        }

        delay(500);
    }

    // povezali smo se na wifi mrežu
    return true;
}

int WifiManager::_findBestNetwork(std::vector<WifiNetwork>& networks) {

    // pretraži dostupne wifi mreže

    WiFi.disconnect();
    WiFi.mode(WIFI_STA);
    int netCount = WiFi.scanNetworks();

    // pronađi najbolju mrežu na koju
    // se uređaj može povezati

    int bestIndex = -1;
    int bestRssi = -1000;

    for(int i = 0; i < netCount; i++) {

        std::string ssid = WiFi.SSID(i).c_str();
        int rssi = WiFi.RSSI(i);

        // možemo li se povezati na mrežu (ssid)
        // tj. imamo li konfiguraciju za nju

        int ni = -1;

        for(int j = 0; j < networks.size(); j++) {
            if(networks[j].ssid == ssid) {
                ni = j;
                break;
            }
        }

        if(ni == -1) {
            // ne možemo se povezati na tu mrežu
            continue;
        }

        if(rssi > bestRssi) {
            bestIndex = ni;
            bestRssi = rssi;
        }

    }

    WiFi.scanDelete();
    return bestIndex;
}

void WifiManager::_startAccessPoint() {

    WiFi.disconnect();
    WiFi.mode(WIFI_AP);

    std::string& ssid = device.name;
    Serial.println(ssid.c_str());

    WiFi.softAP(ssid.c_str());
    
}
