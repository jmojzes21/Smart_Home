
#pragma once

#include <string>

#include "DeviceController.h"
#include "SensorController.h"
#include "DeviceLogger.h"

class AqmController {

  private:

  DeviceController* deviceController;
  SensorController* sensorController;
  DeviceLogger* logs;

  public:

  AqmController(DeviceController* deviceController, SensorController* sensorController, DeviceLogger* logs);

  void init();

  void sendMeasurement(DateTime time, AirQualityHistory& aqData);
  void sendLogs();

  private:

  void sendMeasurement(std::string& data);
  bool sendBufferedMeasurements();
  void saveMeasurementToBuffer(std::string& data);

  void sendLogsInternal();

};
