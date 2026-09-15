
#pragma once


#include "DeviceController.h"
#include "SensorController.h"
#include "WifiController.h"
#include "DeviceLogger.h"

class TelemetryData {

  private:

  boolean _isEmpty = true;

  public:

  DateTime firstUpdate;
  DateTime lastUpdate;

  uint32_t minVoltage = 0;
  uint32_t maxVoltage = 0;

  int minRssi = 0;
  int maxRssi = 0;

  uint32_t heapSize = 0;
  uint32_t maxHeapUsage = 0;

  uint32_t psramSize = 0;
  uint32_t maxPsramUsage = 0;

  size_t storageSize = 0;
  size_t maxUsedStorage = 0;

  TelemetryData() {}

  void updateTime(DateTime& time);

  void updateVoltage(uint32_t voltage);
  void updateRssi(int rssi);

  void updateUsedHeap(uint32_t maxHeapUsage, uint32_t heapSize);
  void updateUsedPsram(uint32_t maxPsramUsage, uint32_t psramSize);

  void updateUsedStorage(size_t usedStorage, size_t storageSize);

  bool isEmpty() { return _isEmpty; }
  void markAsNotEmpty() { _isEmpty = false; }

  bool parse(std::string& json);
  std::string toJson();

};

class DeviceTelemetry {

  private:

  DeviceController* deviceController;
  SensorController* sensorController;
  WifiController* wifiController;
  DeviceLogger* logs;

  TaskHandle_t telemetryTaskHandle;

  TelemetryData telemetry;
  uint32_t nextSaveTime = 0;

  public:

  DeviceTelemetry(DeviceController* deviceController, SensorController* sensorController, WifiController* wifiController, DeviceLogger* logs);

  void init();
  void update();

  private:

  void loadTelemetry();
  void saveTelemetry();

  bool shouldLog(TelemetryData& data, DateTime& now);
  void logTelemetry(TelemetryData& data);

  friend void telemetryTask(void* p);

};
