
#pragma once

#include "DeviceController.h"
#include "SensorController.h"

class AqmController {

  private:

  DeviceController* deviceController;
  SensorController* sensorController;

  public:

  AqmController(DeviceController* deviceController, SensorController* sensorController);

  void init();

  void sendMeasurement(struct tm time, AirQualityHistory& aqData);

  private:

  void sendMeasurement(std::string& data);

  bool sendBufferedMeasurements();

  void saveMeasurementToBuffer(std::string& data);

};
