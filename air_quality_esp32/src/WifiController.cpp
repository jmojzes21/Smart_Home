
#include "WifiController.h"

#include <WiFi.h>
#include <ESPmDNS.h>

#define WIFI_CONNECT_TIMEOUT 10000
#define MDNS_SERVICE "smart-home"

class ScannedWifiNetwork {
  public:

  std::string ssid;
  int rssi;

  ScannedWifiNetwork(std::string ssid, int rssi) {
    this->ssid = ssid;
    this->rssi = rssi;
  }

};

WifiController::WifiController(DeviceController* deviceController) {
  this->deviceController = deviceController;
}

void WifiController::connect() {

  auto& config = deviceController->getConfig();
  auto& networks = config.networks;
  
  if(networks.size() == 0) {
    startAccessPoint();
    return;
  }

  // find available networks and connect to best
  int bestNetwork = findBestNetwork(networks);
  
  if(bestNetwork == -1) {
    startAccessPoint();
    return;
  }

  bool success = connectToNetwork(networks[bestNetwork]);

  if(!success) {
    startAccessPoint();
  }
  
}

void WifiController::initMdns() {

  auto& config = deviceController->getConfig();
  std::string hostname = config.hostname;

  int i = hostname.find(".local");
  if(i != -1) {
    hostname = hostname.substr(0, i);
  }

  MDNS.begin(hostname.c_str());
  MDNS.addService(MDNS_SERVICE, "tcp", HTTP_SERVER_PORT);
}

String WifiController::getLocalIP() {
  return WiFi.localIP().toString();
}

String WifiController::getSSID() {
  return WiFi.SSID();
}

int WifiController::getRSSI() {
  return (int)WiFi.RSSI();
}

int WifiController::findBestNetwork(std::vector<WifiNetwork> &networks) {

  log_i("Start wifi networks scan");

  WiFi.disconnect();
  WiFi.mode(WIFI_STA);
  int netCount = WiFi.scanNetworks();

  std::vector<ScannedWifiNetwork> availableNetworks;

  log_i("Networks found: %d", netCount);
  for(int i = 0; i < netCount; i++) {
    std::string ssid = WiFi.SSID(i).c_str();
    int rssi = WiFi.RSSI(i);
    log_i("  %s (%d dBm)", ssid.c_str(), rssi);

    availableNetworks.emplace_back(ssid, rssi);
  }

  WiFi.scanDelete();

  std::sort(availableNetworks.begin(), availableNetworks.end(), [](ScannedWifiNetwork& a, ScannedWifiNetwork& b) {
    return a.rssi > b.rssi;
  });

  for(auto& net : availableNetworks) {

    auto result = std::find_if(networks.begin(), networks.end(), [&](WifiNetwork& e) {
      return e.ssid == net.ssid;
    });

    if(result != networks.end()) {
      int index = std::distance(networks.begin(), result);
      return index;
    }

  }

  return -1;
}

bool WifiController::connectToNetwork(WifiNetwork &network)
{

  log_i("Connect to wifi %s", network.ssid.c_str());

  WiFi.disconnect();
  WiFi.mode(WIFI_STA);
  WiFi.begin(network.ssid.c_str(), network.password.c_str());

  uint32_t startTime = millis();

  while(!WiFi.isConnected()) {
    if(millis() - startTime >= WIFI_CONNECT_TIMEOUT) {
      break;
    }

    delay(200);
  }

  if(!WiFi.isConnected()) {
    log_i("Can't connect to wifi %s", network.ssid.c_str());
    return false;
  }

  log_i("Connected, ip: %s", WiFi.localIP().toString().c_str());
  return true;
}

void WifiController::startAccessPoint() {

  auto& config = deviceController->getConfig();
  std::string ssid = config.hostname;

  WiFi.disconnect();
  WiFi.mode(WIFI_AP);

  log_i("Start wifi access point %s", ssid.c_str());
  WiFi.softAP(ssid.c_str());

}
