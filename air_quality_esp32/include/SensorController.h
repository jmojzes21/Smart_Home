
#pragma once

#include <Arduino.h>
#include <Adafruit_BME280.h>
#include <SHTC3-SOLDERED.h>
#include <PMS5003.h>
#include <list>

#include "DeviceController.h"

struct Bme280SensorData {
  float temperature;
  float humidity;
  float pressure;
};

struct Shtc3SensorData {
  float temperature;
  float humidity;
};

struct AirQualityData {
  Bme280SensorData bme280;
  Shtc3SensorData shtc3;
  PMS5003_Data pms;
};

struct AirQualityHistory {
  uint32_t timeSeconds;
  float temperature;
  float humidity;
  float pressure;
  uint16_t pm25;
};

void pmsTask(void* param);
void aqHistoryTask(void* param);

class SensorController {

  friend void pmsTask(void* param);
  friend void aqHistoryTask(void* param);

  private:

  DeviceController* deviceController;

  Adafruit_BME280 bme280Sensor;
  SHTC3 shtc3Sensor;
  PMS5003_Sensor pms5003Sensor;
  PMS5003_Data pms5003Data;

  SemaphoreHandle_t i2cSensorMutex;
  SemaphoreHandle_t pmsMutex;
  SemaphoreHandle_t aqHistoryMutex;
  SemaphoreHandle_t vinAdcMutex;

  TaskHandle_t pmsTaskHandle;
  TaskHandle_t aqHistoryTaskHandle;

  std::list<AirQualityHistory> aqHistoryList;
  uint64_t saveAqHistoryTime = 0;

  public:
  
  SensorController(DeviceController* deviceController);

  void init();

  void readSensorData(AirQualityData& aqData);
  uint32_t readInputVoltage();
  
  void saveAirQualityHistory();

  void takeAqHistoryMutex();
  void giveAqHistoryMutex();
  std::list<AirQualityHistory>& getAirQualityHistory();

};
