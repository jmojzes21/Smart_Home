
#include "wifi_manager.h"

static const int wifiConnectTimeout = 4000;

extern Device device;

/// @brief Poveži se na wifi mrežu
/// ili otvori wifi pristupnu točku.
void WifiManager::connectToWifi() {

    // Učitaj postavke
    Settings settings;
    settings.load();

    // Lista wifi mreža
    auto& networks = settings.wifiNetworks;

    // Indeks preferirane mreže ili -1
    int preferred = settings.preferredWifiNetwork;

    // Ako nema zapisanih wifi mreža,
    // otvori wifi pristupnu točku
    if(networks.size() == 0) {
        Serial.printf("Nema wifi mreža za povezivanje\n");
        _startAccessPoint();
        return;
    }

    // Ako imamo preferiranu mrežu,
    // pokušaj se povezati na nju
    if(preferred >= 0 && preferred < networks.size()) {
        
        WifiNetwork& network = networks[preferred];
        bool success = _connectToNetwork(network);

        if(success) {
            // Uspješno povezivanje na preferiranu mrežu
            return;
        }
    }

    // Nema preferirane mreže ili se nismo
    // uspjeli povezati na nju
    
    // Pretraži dostupne wifi mreže i
    // poveži se na najbolju

    int best = _findBestNetwork(networks);

    if(best == -1 || best == preferred) {
        // Nema dostupnih wifi mreža na koje se možemo povezati
        Serial.printf("Nema dostupnih wifi mreža za povezivanje\n");
        _startAccessPoint();
        return;
    }

    // Poveži se na najbolju mrežu

    WifiNetwork& bestNetwork = networks[best];
    bool success = _connectToNetwork(bestNetwork);

    if(success) {
        // Postavi najbolju mrežu kao preferiranu
        settings.preferredWifiNetwork = best;
        settings.save();
    }else{
        // Povezivanje na najbolju mrežu nije moguće
        _startAccessPoint();
    }

}

/// @brief Pokušaj se povezati na wifi mrežu.
/// @param network wifi mreža
/// @return true ako se uspije poveziti, inače false.
bool WifiManager::_connectToNetwork(WifiNetwork& network) {

    Serial.printf("Poveži se na wifi mrežu %s\n", network.ssid.c_str());

    WiFi.disconnect();
    WiFi.mode(WIFI_STA);
    WiFi.begin(network.ssid.c_str(), network.password.c_str());

    uint32_t start = millis();
    while(WiFi.status() != WL_CONNECTED) {

        uint32_t now = millis();
        if(now - start > wifiConnectTimeout) {
            // Nismo se uspjeli povezati na wifi mrežu
            // unutar određenog perioda
            Serial.printf("Povezivanje na mrežu nije uspjelo\n");
            return false;
        }

        delay(500);
    }

    // Povezali smo se na wifi mrežu
    Serial.printf("Povezano\n");
    Serial.printf("  IP: %s\n", WiFi.localIP().toString().c_str());

    return true;
}

/// @brief Pretraži dostupne wifi mreže.
/// Zatim, pronađi wifi mrežu s najboljim signalom za koju znamo lozinku.
/// @param networks mreže na koje se možemo povezati jer znamo lozinku
/// @return indeks najbolje mreže ili -1
int WifiManager::_findBestNetwork(std::vector<WifiNetwork>& networks) {

    // Pretraži dostupne wifi mreže
    Serial.printf("Pretraži dostupne wifi mreže\n");

    WiFi.disconnect();
    WiFi.mode(WIFI_STA);
    int netCount = WiFi.scanNetworks();

    // Pronađi najbolju mrežu na koju
    // se uređaj može povezati

    int bestIndex = -1;
    int bestRssi = -1000;

    Serial.printf("Pronađene mreže:\n");

    for(int i = 0; i < netCount; i++) {

        std::string ssid = WiFi.SSID(i).c_str();
        int rssi = WiFi.RSSI(i);

        Serial.printf("  %s [%d]\n", ssid.c_str(), rssi);

        // Možemo li se povezati na mrežu (ssid),
        // tj. imamo li konfiguraciju za nju

        int ni = -1;

        for(int j = 0; j < networks.size(); j++) {
            if(networks[j].ssid == ssid) {
                ni = j;
                break;
            }
        }

        if(ni == -1) {
            // Ne možemo se povezati na tu mrežu
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

/// @brief Pokreni wifi pristupnu točku.
/// Naziv mreže je jednak nazivu uređaja, a lozinke nema.
void WifiManager::_startAccessPoint() {

    WiFi.disconnect();
    WiFi.mode(WIFI_AP);

    std::string& ssid = device.name;
    
    Serial.printf("Pokreni wifi pristupnu točku\n");
    Serial.printf("  Naziv: %s\n", ssid.c_str());

    WiFi.softAP(ssid.c_str());
    
}
