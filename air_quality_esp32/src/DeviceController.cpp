
#include "DeviceController.h"

#include <ArduinoJson.h>
#include <LittleFS.h>
#include <DasduinoLed.h>

#define WIFI_FILE_PATH "/wifi.json"

DeviceController::DeviceController() {

}

void DeviceController::init() {

  DasduinoLed::init();
  DasduinoLed::setBrightness(20);

  LittleFS.begin(true);

}

void DeviceController::getWifiNetworks(std::vector<WifiNetwork> &networks) {

  File file = LittleFS.open(WIFI_FILE_PATH, FILE_READ);

  if(!file) {
    showColor(LedColors::Orange);
    haltDevice();
  }

  JsonDocument doc;
  deserializeJson(doc, file);
  file.close();

  WifiNetwork network;
  network.ssid = doc["ssid"].as<std::string>();
  network.password = doc["password"].as<std::string>();

  networks.push_back(network);
  
}

void DeviceController::clearLed() {
  DasduinoLed::clear();
}

void DeviceController::showColor(uint32_t color) {
  DasduinoLed::showColor(color);
}

void DeviceController::haltDevice() {
  while(true) {
    delay(1000);
  }
}