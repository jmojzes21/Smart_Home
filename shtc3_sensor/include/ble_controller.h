
#pragma once

#include <BLEDevice.h>
#include <BLEServer.h>
#include <BLEUtils.h>
#include <BLE2902.h>

class MyBleServerCallbacks : public BLEServerCallbacks {
  void onDisconnect(BLEServer* pServer) override;
};

class BleController {

  private:

  BLEServer* _bleServer = nullptr;
  BLEAdvertising* _advertising = nullptr;

  MyBleServerCallbacks* _bleServerCallbacks = nullptr;

  BLEService* _shtc3SensorService = nullptr;
  BLECharacteristic* _shtc3DataChar = nullptr;

  public:

  BleController();

  void init();
  void sendSensorData(float temperature, float humidity);

};
