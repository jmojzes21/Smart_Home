
#include "WifiController.h"

#include <WiFi.h>
#include <ESPmDNS.h>
#include <LedColors.h>

#define WIFI_CONNECT_TIMEOUT 10000

WifiController::WifiController(DeviceController* deviceController) {
  this->deviceController = deviceController;
}

void WifiController::connect(std::vector<WifiNetwork>& networks) {

  deviceController->showColor(LedColors::Blue);

  WifiNetwork& network = networks[0];

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
    deviceController->showColor(LedColors::Orange);
    deviceController->haltDevice();
  }
  
  deviceController->clearLed();

}

void WifiController::initMdns() {
  MDNS.begin(DEVICE_HOSTNAME);
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
