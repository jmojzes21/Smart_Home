
#include <Arduino.h>
#include <Wire.h>
#include <LedColors.h>

#include "DeviceController.h"
#include "SensorController.h"
#include "WifiController.h"
#include "RestController.h"


DeviceController* deviceController;
SensorController* sensorController;
WifiController* wifiController;
RestController* restController;

void setup() {

  Serial.begin(115200);

  Wire.begin();

  deviceController = new DeviceController();
  sensorController = new SensorController(deviceController);
  wifiController = new WifiController(deviceController);
  restController = new RestController(deviceController, sensorController, wifiController);

  deviceController->init();
  sensorController->init();
  
  deviceController->showColor(LedColors::Blue);

  wifiController->connect();
  restController->init();

  wifiController->initMdns();

  deviceController->clearLed();

}

void loop() {
  delay(10000);
}
