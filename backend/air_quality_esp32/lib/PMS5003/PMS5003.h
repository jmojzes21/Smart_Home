
#pragma once

#include <Arduino.h>

class PMS5003_Data {

  private:
  uint16_t _header;
  uint16_t _frameLength;

  public:
  uint16_t pm_10_std;
  uint16_t pm_25_std;
  uint16_t pm_100_std;

  uint16_t pm_10_env;
  uint16_t pm_25_env;
  uint16_t pm_100_env;

  uint16_t particles_03;
  uint16_t particles_05;
  uint16_t particles_10;
  uint16_t particles_25;
  uint16_t particles_50;
  uint16_t particles_100;

  private:
  uint16_t _reserved;
  uint16_t _checkSum;

  friend class PMS5003_Sensor;

};

class PMS5003_Sensor {

  private:

  HardwareSerial* _serial = nullptr;
  int8_t _rxPin = 0;
  int8_t _txPin = 0;

  uint8_t _passiveMode[7] = {0x42, 0x4D, 0xE1, 0x00, 0x00, 0x01, 0x70};
  uint8_t _passiveRead[7] = {0x42, 0x4D, 0xE2, 0x00, 0x00, 0x01, 0x71};

  public:

  PMS5003_Sensor();

  void init(HardwareSerial* serial, int8_t rxPin, int8_t txPin);
  bool read(PMS5003_Data* data);

  private:

  void _clearRxBuffer();

};
