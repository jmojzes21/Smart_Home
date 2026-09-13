
#include "AqmController.h"

#include <ArduinoJson.h>
#include <HTTPClient.h>
#include <LittleFS.h>
#include <memory>
#include <cstdarg>

#include "helpers/DateFormats.h"

#define AQM_CONNECT_TIMEOUT_MS 5000
#define AQM_TCP_TIMEOUT_MS 5000

#define MEASUREMENTS_BUFFER_FILE_PATH "/buffer.txt"
#define LOGS_FILE_PATH "/logs.txt"

#define AQM_LOG_INFO "I"
#define AQM_LOG_WARNING "W"
#define AQM_LOG_ERROR "E"

#define LOG_QUEUE_SIZE 100

std::string formatString(const char *format, va_list args);

AqmController::AqmController(DeviceController* deviceController, SensorController* sensorController) {
  this->deviceController = deviceController;
  this->sensorController = sensorController;
}

void AqmController::init() {

  logQueue = xQueueCreate(LOG_QUEUE_SIZE, sizeof(std::string*));
  logFileMutex = xSemaphoreCreateMutex();

  xTaskCreateUniversal(saveLogsTask, "saveLogs", 8192, this, 1, &saveLogsTaskHandle, ARDUINO_RUNNING_CORE);

  sensorController->setOnSaveDataAqm([&](struct tm time, AirQualityHistory& aqData) {
    sendMeasurement(time, aqData);
    sendLogs();
  });

}

void AqmController::sendMeasurement(tm time, AirQualityHistory &aqData) {

  auto& config = deviceController->getConfig();

  std::string timeText = DateFormats::formatDateTime(time);
  
  JsonDocument doc;

  doc["station_id"] = config.aqmDeviceUuid;
  doc["time"] = timeText;

  doc["temp_c"] = aqData.temperatureMetrics.getAverage();
  doc["press_hpa"] = aqData.pressureMetrics.getAverage();
  doc["hum_p"] = aqData.humidityMetrics.getAverage();
  doc["pm2p5_ugm3"] = aqData.pm25Metrics.getAverage();

  std::string body = "";
  serializeJson(doc, body);

  sendMeasurement(body);
}

void AqmController::sendMeasurement(std::string& data) {

  bool isBufferEmpty = sendBufferedMeasurements();

  if(!isBufferEmpty) {
    saveMeasurementToBuffer(data);
    return;
  }

  auto& config = deviceController->getConfig();
  auto& aqmHost = config.aqmBackendAddress;
  auto& apiKey = config.aqmApiKey;

  std::string url = aqmHost + "/api/air-quality";
  
  log_i("POST %s", url.c_str());
  log_i("Body %s", data.c_str());

  url += "?apiKey=" + apiKey;

  // send request

  HTTPClient client;
  client.setConnectTimeout(AQM_CONNECT_TIMEOUT_MS);
  client.setTimeout(AQM_TCP_TIMEOUT_MS);

  if(!client.begin(url.c_str())) {
    saveMeasurementToBuffer(data);
    return;
  }

  int statusCode = client.POST((uint8_t*)data.c_str(), data.length());
  log_i("Status: %d", statusCode);

  if(statusCode != 204) {
    String response = statusCode > 0 ? client.getString() : client.errorToString(statusCode);
    log_e("%s", response.c_str());

    logError("Nije moguće poslati izmjerene vrijednosti, POST /api/air-quality, status: %d, odgovor: %s", statusCode, response.c_str());
    saveMeasurementToBuffer(data);
  }

  client.end();

}

bool AqmController::sendBufferedMeasurements() {

  if(!LittleFS.exists(MEASUREMENTS_BUFFER_FILE_PATH)) {
    return true;
  }

  log_i("Send buffered measurements");

  File file = LittleFS.open(MEASUREMENTS_BUFFER_FILE_PATH, FILE_READ);
  if(!file) {
    log_e("Can't open file %s", MEASUREMENTS_BUFFER_FILE_PATH);
    return false;
  }

  size_t fileSize = file.size();

  std::vector<char> data;
  data.resize(fileSize + 4, 0);

  data[0] = '[';
  file.readBytes(&data[1], fileSize);
  file.close();
  data[fileSize + 1] = ']';

  // send request

  auto& config = deviceController->getConfig();
  auto& aqmHost = config.aqmBackendAddress;
  auto& apiKey = config.aqmApiKey;

  std::string url = aqmHost + "/api/air-quality/bulk";
  log_i("POST %s", url.c_str());
  url += "?apiKey=" + apiKey;

  HTTPClient client;
  client.setConnectTimeout(AQM_CONNECT_TIMEOUT_MS);
  client.setTimeout(AQM_TCP_TIMEOUT_MS);

  if(!client.begin(url.c_str())) {
    return false;
  }

  int statusCode = client.POST((uint8_t*)data.data(), fileSize + 2);
  log_i("Status: %d", statusCode);

  if(statusCode != 201) {
    String response = statusCode > 0 ? client.getString() : client.errorToString(statusCode);
    log_e("%s", response.c_str());

    logError("Nije moguće poslati mjerenja iz međuspremnika, POST /api/air-quality/bulk, status: %d, odgovor: %s", statusCode, response.c_str());

    client.end();
    return false;
  }

  String response = client.getString();
  client.end();

  JsonDocument doc;
  deserializeJson(doc, response);
  
  int count = doc["count"];
  logInfo("Mjerenja iz međuspremnika su uspješno poslana, ukupno: %d", count);

  LittleFS.remove(MEASUREMENTS_BUFFER_FILE_PATH);
  return true;
}

void AqmController::saveMeasurementToBuffer(std::string& data) {
  
  log_i("Save measurement to buffer %s", data.c_str());
  logInfo("Spremi izmjerene vrijednosti međuspremnik");

  bool append = LittleFS.exists(MEASUREMENTS_BUFFER_FILE_PATH);

  File file = LittleFS.open(MEASUREMENTS_BUFFER_FILE_PATH, append ? FILE_APPEND : FILE_WRITE);
  if(!file) {
    log_e("Can't open file %s", MEASUREMENTS_BUFFER_FILE_PATH);
    return;
  }

  if(append) {
    file.print(',');
  }
  
  file.print(data.c_str());
  file.close();

}


void AqmController::logInfo(const char* format, ...) {
  va_list args;
  va_start(args, format);
  std::string body = formatString(format, args);
  va_end(args);

  log_i("%s", body.c_str());
  saveLog(AQM_LOG_INFO, body);
}

void AqmController::logWarning(const char* format, ...) {
  va_list args;
  va_start(args, format);
  std::string body = formatString(format, args);
  va_end(args);

  log_w("%s", body.c_str());
  saveLog(AQM_LOG_WARNING, body);
}

void AqmController::logError(const char* format, ...) {
  va_list args;
  va_start(args, format);
  std::string body = formatString(format, args);
  va_end(args);

  log_e("%s", body.c_str());
  saveLog(AQM_LOG_ERROR, body);
}

void AqmController::saveLog(const char* level, std::string& body) {

  time_t timeNow;
  struct tm timeInfo;

  time(&timeNow);
  localtime_r(&timeNow, &timeInfo);

  std::string timeText = DateFormats::formatDateTime(timeInfo);

  JsonDocument doc;
  doc.add(timeText);
  doc.add(level);
  doc.add(body);

  doc.shrinkToFit();

  std::string* data = new std::string("");
  serializeJson(doc, *data);

  xQueueSend(logQueue, &data, portMAX_DELAY);

}


void AqmController::sendLogs() {
  xSemaphoreTake(logFileMutex, portMAX_DELAY);
  sendLogsInternal();
  xSemaphoreGive(logFileMutex);
}

void AqmController::sendLogsInternal() {

  if(!LittleFS.exists(LOGS_FILE_PATH)) {
    return;
  }

  log_i("Send logs");

  File file = LittleFS.open(LOGS_FILE_PATH, FILE_READ);
  if(!file) {
    log_e("Can't open file %s", LOGS_FILE_PATH);
    return;
  }

  size_t fileSize = file.size();

  std::vector<char> data;
  data.resize(fileSize + 4, 0);

  data[0] = '[';
  file.readBytes(&data[1], fileSize);
  file.close();
  data[fileSize + 1] = ']';

  // send request

  auto& config = deviceController->getConfig();
  auto& aqmHost = config.aqmBackendAddress;
  auto& deviceUuid = config.aqmDeviceUuid;
  auto& apiKey = config.aqmApiKey;

  std::string url = aqmHost + "/api/station-log/" + deviceUuid;
  log_i("POST %s", url.c_str());
  url += "?apiKey=" + apiKey;

  HTTPClient client;
  client.setConnectTimeout(AQM_CONNECT_TIMEOUT_MS);
  client.setTimeout(AQM_TCP_TIMEOUT_MS);

  if(!client.begin(url.c_str())) {
    return;
  }

  int statusCode = client.POST((uint8_t*)data.data(), fileSize + 2);
  log_i("Status: %d", statusCode);

  if(statusCode != 201) {
    String response = statusCode > 0 ? client.getString() : client.errorToString(statusCode);
    log_e("%s", response.c_str());

    logError("Nije moguće poslati logove, POST /api/station-log, status: %d, odgovor: %s", statusCode, response.c_str());

    client.end();
    return;
  }

  client.end();
  LittleFS.remove(LOGS_FILE_PATH);
  
}


void saveLogsTask(void* p) {

  AqmController* aqmController = (AqmController*)p;

  QueueHandle_t queue = aqmController->logQueue;
  SemaphoreHandle_t logFileMutex = aqmController->logFileMutex;

  while(true) {

    std::string* data;
    xQueueReceive(queue, &data, portMAX_DELAY);

    xSemaphoreTake(logFileMutex, portMAX_DELAY);

    bool append = LittleFS.exists(LOGS_FILE_PATH);

    File file = LittleFS.open(LOGS_FILE_PATH, append ? FILE_APPEND : FILE_WRITE);
    if(!file) {
      log_e("Can't open file %s", LOGS_FILE_PATH);
      return;
    }

    if(append) {
      file.print(',');
    }
    
    file.print(data->c_str());
    file.close();

    xSemaphoreGive(logFileMutex);

  }

}


std::string formatString(const char *format, va_list args) {

  std::vector<char> buffer;
  buffer.resize(64, 0);

  va_list argsCopy;
  va_copy(argsCopy, args);

  size_t len = vsnprintf(buffer.data(), buffer.size(), format, argsCopy);
  va_end(argsCopy);

  if(len >= buffer.size()) {
    buffer.resize(len + 1, 0);
    vsnprintf(buffer.data(), buffer.size(), format, args);
  }

  return std::string(buffer.data());
}
