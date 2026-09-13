
#include <Arduino.h>
#include <Wire.h>
#include <LedColors.h>
#include <LittleFS.h>

#include "DeviceController.h"
#include "SensorController.h"
#include "WifiController.h"
#include "RestController.h"
#include "AqmController.h"

DeviceController* deviceController;
SensorController* sensorController;
WifiController* wifiController;
RestController* restController;
AqmController* aqmController;

void setup() {

  Serial.begin(115200);

  Wire.begin();

  deviceController = new DeviceController();
  sensorController = new SensorController(deviceController);
  wifiController = new WifiController(deviceController);
  restController = new RestController(deviceController, sensorController, wifiController);
  aqmController = new AqmController(deviceController, sensorController);

  LittleFS.begin(true);

  deviceController->init();
  sensorController->init();
  
  deviceController->showColor(LedColors::Blue);

  wifiController->connect();
  restController->init();
  aqmController->init();

  wifiController->initMdns();
  deviceController->clearLed();

}

void loop() {
  delay(10000);
}
