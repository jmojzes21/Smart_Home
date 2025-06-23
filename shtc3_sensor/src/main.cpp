
#include <Arduino.h>
#include <SHTC3-SOLDERED.h>

#include "ble_controller.h"

SHTC3 shtc3Sensor;
BleController bleController;

void setup() {
  shtc3Sensor.begin();
  bleController.init();
}

void loop() {

  shtc3Sensor.sample();

  float temperature = shtc3Sensor.readTempC();
  float humidity = shtc3Sensor.readHumidity();

  bleController.sendSensorData(temperature, humidity);

  delay(2000);

}
