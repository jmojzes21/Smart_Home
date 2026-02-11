
#pragma once

#include <Arduino.h>
#include <Adafruit_BME280.h>
#include <SHTC3-SOLDERED.h>
#include <PMS5003.h>
#include <list>

#include "DeviceController.h"
#include "Metrics.h"


struct Bme280SensorData {
  float temperature = 0;
  float humidity = 0;
  float pressure = 0;
};

struct Shtc3SensorData {
  float temperature = 0;
  float humidity = 0;
};

struct AirQualityData {
  Bme280SensorData bme280;
  Shtc3SensorData shtc3;

  float temperature = 0;
  float humidity = 0;
  float pressure = 0;

  PMS5003_Data pms;
};

struct AirQualityHistory {

  uint32_t timeSeconds = 0;

  Metrics temperatureMetrics;
  Metrics humidityMetrics;
  Metrics pressureMetrics;
  Metrics pm25Metrics;
  
};

class AirQualityMetrics {
  public:

  Metrics temperatureMetrics;
  Metrics humidityMetrics;
  Metrics pressureMetrics;
  Metrics pm25Metrics;

  void reset();

};


typedef std::function<void(AirQualityData& aqData)> SensorDataHandler;

class SensorController {

  private:

  DeviceController* deviceController;

  Adafruit_BME280 bme280Sensor;
  SHTC3 shtc3Sensor;
  PMS5003_Sensor pms5003Sensor;

  AirQualityData aqData;
  AirQualityMetrics aqMetrics;

  SemaphoreHandle_t aqDataMutex;
  SemaphoreHandle_t aqHistoryMutex;
  SemaphoreHandle_t vinAdcMutex;

  TaskHandle_t pmsTaskHandle;
  TaskHandle_t aqHistoryTaskHandle;

  std::list<AirQualityHistory> aqHistoryList;

  SensorDataHandler onSensorData = nullptr;

  public:
  
  SensorController(DeviceController* deviceController);

  void init();

  DeviceController* getDeviceController();

  AirQualityData getAirQuality();

  void readSensorData();
  uint32_t readInputVoltage();
  
  void saveAirQualityHistory();

  void takeAqHistoryMutex();
  void giveAqHistoryMutex();

  void clearAirQualityHistory();
  std::list<AirQualityHistory>& getAirQualityHistory();

  void setOnSensorData(SensorDataHandler handler);

};
