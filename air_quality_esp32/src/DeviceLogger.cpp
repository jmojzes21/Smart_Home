
#include "DeviceLogger.h"

#include <vector>
#include <cstdarg>
#include <LittleFS.h>
#include <ArduinoJson.h>

#include "helpers/DateFormats.h"

#define DEVICE_LOG_INFO "I"
#define DEVICE_LOG_WARNING "W"
#define DEVICE_LOG_ERROR "E"

#define LOG_QUEUE_SIZE 100


void saveLogsTask(void* p);
std::string formatString(const char *format, va_list args);

void DeviceLogger::init() {

  logQueue = xQueueCreate(LOG_QUEUE_SIZE, sizeof(std::string*));
  logFileMutex = xSemaphoreCreateMutex();

  xTaskCreateUniversal(saveLogsTask, "saveLogs", 8192, this, 1, &saveLogsTaskHandle, ARDUINO_RUNNING_CORE);

}

void DeviceLogger::logInfo(const char* format, ...) {

  struct tm timeInfo = getTime();

  va_list args;
  va_start(args, format);
  std::string body = formatString(format, args);
  va_end(args);

  log_i("%s", body.c_str());
  saveLog(timeInfo, DEVICE_LOG_INFO, body);
}

void DeviceLogger::logWarning(const char* format, ...) {

  struct tm timeInfo = getTime();

  va_list args;
  va_start(args, format);
  std::string body = formatString(format, args);
  va_end(args);

  log_w("%s", body.c_str());
  saveLog(timeInfo, DEVICE_LOG_WARNING, body);
}

void DeviceLogger::logError(const char* format, ...) {

  struct tm timeInfo = getTime();

  va_list args;
  va_start(args, format);
  std::string body = formatString(format, args);
  va_end(args);

  log_e("%s", body.c_str());
  saveLog(timeInfo, DEVICE_LOG_ERROR, body);
}

void DeviceLogger::saveLog(struct tm timeInfo, const char* level, std::string& body) {

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

tm DeviceLogger::getTime() {
  time_t timeNow;
  struct tm timeInfo;

  time(&timeNow);
  localtime_r(&timeNow, &timeInfo);

  return timeInfo;
}

std::string DeviceLogger::formatString(const char *format, va_list args) {

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

void DeviceLogger::takeLogFileMutex() {
  xSemaphoreTake(logFileMutex, portMAX_DELAY);
}

void DeviceLogger::giveLogFileMutex() {
  xSemaphoreGive(logFileMutex);
}

void saveLogsTask(void* p) {

  DeviceLogger* logs = (DeviceLogger*)p;

  QueueHandle_t queue = logs->logQueue;
  SemaphoreHandle_t logFileMutex = logs->logFileMutex;

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
