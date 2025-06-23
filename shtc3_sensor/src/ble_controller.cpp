
#include "ble_controller.h"

#define DEVICE_NAME "SHTC3 Temperature Sensor"

#define SHTC3_SENSOR_SERVICE_UUID   0x2020
#define SHTC3_DATA_CHAR_UUID        0x2021

void MyBleServerCallbacks::onDisconnect(BLEServer* pServer) {
  pServer->getAdvertising()->start();
}

BleController::BleController() {}

void BleController::init() {

  BLEDevice::init(DEVICE_NAME);
  _bleServer = BLEDevice::createServer();

  _bleServerCallbacks = new MyBleServerCallbacks();
  _bleServer->setCallbacks(_bleServerCallbacks);

  _shtc3SensorService = _bleServer->createService((uint16_t)SHTC3_SENSOR_SERVICE_UUID);

  _shtc3DataChar = _shtc3SensorService->createCharacteristic(
    (uint16_t)SHTC3_DATA_CHAR_UUID,
    BLECharacteristic::PROPERTY_READ | BLECharacteristic::PROPERTY_WRITE | BLECharacteristic::PROPERTY_INDICATE | BLECharacteristic::PROPERTY_NOTIFY
  );
  _shtc3DataChar->addDescriptor(new BLE2902());

  _shtc3SensorService->start();

  _advertising = BLEDevice::getAdvertising();
  _advertising->addServiceUUID((uint16_t)SHTC3_SENSOR_SERVICE_UUID);
  _advertising->setScanResponse(false);
  _advertising->setMinPreferred(0);
  _advertising->start();

}

void BleController::sendSensorData(float temperature, float humidity) {

  uint8_t buffer[8];
  memcpy(buffer, &temperature, 4);
  memcpy(buffer + 4, &humidity, 4);
  
  _shtc3DataChar->setValue(buffer, 8);
  _shtc3DataChar->notify();

}
