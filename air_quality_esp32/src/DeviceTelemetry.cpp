
#include "DeviceTelemetry.h"

#define LOG_TELEMETRY_DATA_DELAY_SECONDS (10 * 60)

void logTelemetryTask(void *p);


DeviceTelemetry::DeviceTelemetry(SensorController* sensorController, WifiController* wifiController, DeviceLogger* logs) {
  this->sensorController = sensorController;
  this->wifiController = wifiController;
  this->logs = logs;
}

void DeviceTelemetry::init() {

  xTaskCreateUniversal(logTelemetryTask, "logTelemetry", 8192, this, 0, &logTelemetryTaskHandle, ARDUINO_RUNNING_CORE);

}

static float bytesToKiloBytes(uint32_t bytes) {
  return (float)bytes / 1024.0f;
}

void DeviceTelemetry::logData() {

  float inputVoltage = (float)sensorController->readInputVoltage() / 1000.0f;
  int rssi = wifiController->getRSSI();

  uint32_t heapSize = ESP.getHeapSize();
  uint32_t minFreeHeap = ESP.getMinFreeHeap();
  float heapSizeKB = bytesToKiloBytes(heapSize);
  float maxUsedHeapKB = bytesToKiloBytes(heapSize - minFreeHeap);
  float maxUsedHeapPercent = (maxUsedHeapKB / heapSizeKB) * 100.0f;
  

  uint32_t psramSize = ESP.getPsramSize();
  uint32_t minFreePsram = ESP.getMinFreePsram();
  float psramSizeKB = bytesToKiloBytes(psramSize);
  float maxUsedPsramKB = bytesToKiloBytes(psramSize - minFreePsram);
  float maxUsedPsramPercent = (maxUsedPsramKB / psramSizeKB) * 100.0f;

  logs->logInfo(
    "Stanje postaje\n"
    "Napon: %.2f V\n"
    "RSSI: %d dBm\n"
    "RAM: max %.2f / %.2f KB (%.2f %c)\n"
    "PSRAM: max %.2f / %.2f KB (%.2f %c)",
    inputVoltage, rssi,
    maxUsedHeapKB, heapSizeKB, maxUsedHeapPercent, '%',
    maxUsedPsramKB, psramSizeKB, maxUsedPsramPercent, '%'
  );

}

void logTelemetryTask(void* p) {

  DeviceTelemetry* telemetry = (DeviceTelemetry*)p;
  uint32_t period = LOG_TELEMETRY_DATA_DELAY_SECONDS * 1000;
  uint32_t t1 = millis() + period;
 
  while(true) {

    uint32_t now = millis();
    if(now >= t1) {
      t1 = now + period;
      telemetry->logData();
    }

    delay(10000);
  }

}
