
#include "DeviceTelemetry.h"

#include <ArduinoJson.h>
#include <LittleFS.h>

#define JSON_FIRST_UPDATE "t0"
#define JSON_LAST_UPDATE  "t1"

#define JSON_MIN_VOLTAGE  "minv"
#define JSON_MAX_VOLTAGE  "maxv"
#define JSON_MIN_RSSI     "minrs"
#define JSON_MAX_RSSI     "maxrs"

#define JSON_HEAP_SIZE    "heap"
#define JSON_MAX_HEAP     "mheap"
#define JSON_PSRAM_SIZE   "pram"
#define JSON_MAX_PSRAM    "mpram"

#define JSON_FS_SIZE      "fs"
#define JSON_MAX_FS       "ufs"

#define UPDATE_TELEMETRY_PERIOD_SECONDS (30)
#define SAVE_TELEMETRY_PERIOD_MS (300 * 1000)

#define TELEMETRY_FILE_PATH "/telemetry.json"

void telemetryTask(void *p);

static float bytesToKiloBytes(uint32_t bytes) {
  return (float)bytes / 1024.0f;
}

DeviceTelemetry::DeviceTelemetry(DeviceController* deviceController, SensorController* sensorController, WifiController* wifiController, DeviceLogger* logs) {
  this->deviceController = deviceController;
  this->sensorController = sensorController;
  this->wifiController = wifiController;
  this->logs = logs;
}

void DeviceTelemetry::init() {

  loadTelemetry();

  xTaskCreateUniversal(telemetryTask, "telemetry", 8192, this, 0, &telemetryTaskHandle, ARDUINO_RUNNING_CORE);

  nextSaveTime = 0;
}

void DeviceTelemetry::update() {

  DateTime now = deviceController->getDateTime();
  
  bool shouldLog = this->shouldLog(telemetry, now);
  bool mustSave = shouldLog;

  if(shouldLog) {
    logTelemetry(telemetry);
    telemetry = TelemetryData();
  }

  // update telemetry data

  telemetry.updateTime(now);

  uint32_t voltage = sensorController->readInputVoltage();
  telemetry.updateVoltage(voltage);

  int rssi = wifiController->getRSSI();
  telemetry.updateRssi(rssi);

  uint32_t heapSize = ESP.getHeapSize();
  uint32_t maxUsedHeap = heapSize - ESP.getMinFreeHeap();
  telemetry.updateUsedHeap(maxUsedHeap, heapSize);

  uint32_t psramSize = ESP.getPsramSize();
  uint32_t maxUsedPsram = psramSize - ESP.getMinFreePsram();
  telemetry.updateUsedPsram(maxUsedPsram, psramSize);

  size_t storageSize = LittleFS.totalBytes();
  size_t usedStorage = LittleFS.usedBytes();
  telemetry.updateUsedStorage(usedStorage, storageSize);

  telemetry.markAsNotEmpty();

  // save telemetry

  uint32_t tnow = millis(); 
  if(mustSave || tnow >= nextSaveTime) {
    nextSaveTime = tnow + SAVE_TELEMETRY_PERIOD_MS;
    saveTelemetry();
  }

}

void DeviceTelemetry::loadTelemetry() {

  bool exists = LittleFS.exists(TELEMETRY_FILE_PATH);
  if(!exists) return;

  log_i("Load telemetry");

  File file = LittleFS.open(TELEMETRY_FILE_PATH, FILE_READ);
  if(!file) {
    log_e("Can't open file %s", TELEMETRY_FILE_PATH);
    return;
  }

  std::string data(file.size(), ' ');
  file.readBytes((char*)data.data(), file.size());
  file.close();

  TelemetryData telemetry;
  if(!telemetry.parse(data)) {
    log_e("Can't parse telemetry %s", data.c_str());
    return;
  }

  this->telemetry = telemetry;
  this->telemetry.markAsNotEmpty();

}

void DeviceTelemetry::saveTelemetry() {

  log_i("Save telemetry");

  std::string tJson = telemetry.toJson();

  File file = LittleFS.open(TELEMETRY_FILE_PATH, FILE_WRITE);
  if(!file) {
    log_e("Can't open file %s", TELEMETRY_FILE_PATH);
    return;
  }

  file.write((uint8_t*)tJson.c_str(), tJson.length());
  file.close();

}

bool DeviceTelemetry::shouldLog(TelemetryData& data, DateTime& now) {
  if (data.isEmpty()) {
    return false;
  }

  DateTime& firstUpdate = data.firstUpdate;
  return firstUpdate.day != now.day || firstUpdate.month != now.month || firstUpdate.year != now.year;
}

void DeviceTelemetry::logTelemetry(TelemetryData& data) {
  
  float minVoltage = data.minVoltage / 1000.0f;
  float maxVoltage = data.maxVoltage / 1000.0f;

  float usedHeap = bytesToKiloBytes(data.maxHeapUsage);
  float heapSize = bytesToKiloBytes(data.heapSize);
  float usedHeapPercent = (usedHeap / heapSize) * 100.0f;

  float usedPsram = bytesToKiloBytes(data.maxPsramUsage);
  float psramSize = bytesToKiloBytes(data.psramSize);
  float usedPsramPercent = (usedPsram / psramSize) * 100.0f;

  float usedStorage = bytesToKiloBytes(data.maxUsedStorage);
  float storageSize = bytesToKiloBytes(data.storageSize);
  float usedStoragePercent = (usedStorage / storageSize) * 100.0f;

  logs->logInfo(
    "Stanje postaje\n"
    "[Vrijeme]  %s\n"
    "[Napon]  min: %.2f, max: %.2f (V)\n"
    "[RSSI]  min: %d, max: %d (dBm)\n"
    "[Heap]  max %.2f / %.2f KB (%.2f%c)\n"
    "[PSRAM]  max %.2f / %.2f KB (%.2f%c)\n"
    "[Pohrana]  max %.2f / %.2f KB (%.2f%c)",

    data.lastUpdate.toString().c_str(),
    minVoltage, maxVoltage,
    data.minRssi, data.maxRssi,
    usedHeap, heapSize, usedHeapPercent, '%',
    usedPsram, psramSize, usedPsramPercent, '%',
    usedStorage, storageSize, usedStoragePercent, '%'
  );

}

void telemetryTask(void* p) {

  DeviceTelemetry* telemetry = (DeviceTelemetry*)p;
  uint32_t period = UPDATE_TELEMETRY_PERIOD_SECONDS * 1000;
  uint32_t nextUpdate = millis() + period;
 
  while(true) {

    uint32_t now = millis();
    if(now >= nextUpdate) {
      nextUpdate = now + period;
      telemetry->update();
    }

    delay(2000);
  }

}

void TelemetryData::updateTime(DateTime &time) {
  if(_isEmpty) {
    firstUpdate = time;
  }

  lastUpdate = time;
}

void TelemetryData::updateVoltage(uint32_t voltage) {
  if (voltage > maxVoltage || _isEmpty) {
    maxVoltage = voltage;
  }

  if (voltage < minVoltage || _isEmpty) {
    minVoltage = voltage;
  }
}

void TelemetryData::updateRssi(int rssi) {
  if(rssi > maxRssi || _isEmpty) {
    maxRssi = rssi;
  }
  
  if(rssi < minRssi || _isEmpty) {
    minRssi = rssi;
  }
}

void TelemetryData::updateUsedHeap(uint32_t heapUsage, uint32_t heapSize) {
  if(heapUsage > this->maxHeapUsage || _isEmpty) {
    this->maxHeapUsage = heapUsage;
    this->heapSize = heapSize;
  }
}

void TelemetryData::updateUsedPsram(uint32_t psramUsage, uint32_t psramSize) {
  if(psramUsage > this->maxPsramUsage || _isEmpty) {
    this->maxPsramUsage = psramUsage;
    this->psramSize = psramSize;
  }
}

void TelemetryData::updateUsedStorage(size_t usedStorage, size_t storageSize) {
  if(usedStorage > this->maxUsedStorage || _isEmpty) {
    this->maxUsedStorage = usedStorage;
    this->storageSize = storageSize;
  }
}

bool TelemetryData::parse(std::string& json) {

  JsonDocument doc;

  auto error = deserializeJson(doc, json);
  if(error) {
    return false;
  }

  std::string firstUpdate = doc[JSON_FIRST_UPDATE];
  if(!DateTime::fromString(firstUpdate, &this->firstUpdate)) return false;

  std::string lastUpdate = doc[JSON_LAST_UPDATE];
  if(!DateTime::fromString(lastUpdate, &this->lastUpdate)) return false;

  minVoltage = doc[JSON_MIN_VOLTAGE];
  maxVoltage = doc[JSON_MAX_VOLTAGE];

  minRssi = doc[JSON_MIN_RSSI];
  maxRssi = doc[JSON_MAX_RSSI];

  heapSize = doc[JSON_HEAP_SIZE];
  maxHeapUsage = doc[JSON_MAX_HEAP];

  psramSize = doc[JSON_PSRAM_SIZE];
  maxPsramUsage = doc[JSON_MAX_PSRAM];

  storageSize = doc[JSON_FS_SIZE];
  maxUsedStorage = doc[JSON_MAX_FS];

  return true;
}

std::string TelemetryData::toJson() {

  JsonDocument doc;

  doc[JSON_FIRST_UPDATE] = firstUpdate.toString();
  doc[JSON_LAST_UPDATE] = lastUpdate.toString();

  doc[JSON_MIN_VOLTAGE] = minVoltage;
  doc[JSON_MAX_VOLTAGE] = maxVoltage;

  doc[JSON_MIN_RSSI] = minRssi;
  doc[JSON_MAX_RSSI] = maxRssi;

  doc[JSON_HEAP_SIZE] = heapSize;
  doc[JSON_MAX_HEAP] = maxHeapUsage;

  doc[JSON_PSRAM_SIZE] = psramSize;
  doc[JSON_MAX_PSRAM] = maxPsramUsage;

  doc[JSON_FS_SIZE] = storageSize;
  doc[JSON_MAX_FS] = maxUsedStorage;

  std::string output = "";
  serializeJson(doc, output);

  return output;
}
