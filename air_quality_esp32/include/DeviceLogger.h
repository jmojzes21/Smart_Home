
#pragma once

#include <string>
#include <Arduino.h>
#include "helpers/DateTime.h"

#define LOGS_FILE_PATH "/logs.txt"

class DeviceLogger {

  private:

  QueueHandle_t logQueue;
  TaskHandle_t saveLogsTaskHandle;

  SemaphoreHandle_t logFileMutex;

  public:

  DeviceLogger() {}

  void init();

  void logInfo(const char* format, ...);
  void logWarning(const char* format, ...);
  void logError(const char* format, ...);

  void takeLogFileMutex();
  void giveLogFileMutex();

  private:

  void saveLog(DateTime& time, const char* level, std::string& body);

  DateTime getTime();
  std::string formatString(const char *format, va_list args);


  friend void saveLogsTask(void* p);

};
