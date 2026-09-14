
#pragma once


#include "DeviceController.h"
#include "SensorController.h"
#include "WifiController.h"
#include "DeviceLogger.h"


class DeviceTelemetry {

  private:

  SensorController* sensorController;
  WifiController* wifiController;
  DeviceLogger* logs;

  TaskHandle_t logTelemetryTaskHandle;

  public:

  DeviceTelemetry(SensorController* sensorController, WifiController* wifiController, DeviceLogger* logs);

  void init();
  void logData();

  friend void logTelemetryTask(void* p);

};
