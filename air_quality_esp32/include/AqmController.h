
#pragma once

#include <string>
#include <vector>
#include <Arduino.h>

#include "DeviceController.h"
#include "SensorController.h"

class AqmController {

  private:

  DeviceController* deviceController;
  SensorController* sensorController;

  QueueHandle_t logQueue;
  TaskHandle_t saveLogsTaskHandle;

  SemaphoreHandle_t logFileMutex;

  public:

  AqmController(DeviceController* deviceController, SensorController* sensorController);

  void init();

  void sendMeasurement(struct tm time, AirQualityHistory& aqData);

  void logInfo(const char* format, ...);
  void logWarning(const char* format, ...);
  void logError(const char* format, ...);

  void sendLogs();

  private:

  void sendMeasurement(std::string& data);
  bool sendBufferedMeasurements();
  void saveMeasurementToBuffer(std::string& data);

  void saveLog(const char* level, std::string& body);
  void sendLogsInternal();

  friend void saveLogsTask(void* p);

};
