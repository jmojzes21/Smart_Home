
#include "DateFormats.h"
#include <stdio.h>

void DateFormats::formatDateTime(tm t, char *buffer, size_t bufferSize) {
  snprintf(buffer, bufferSize, "%04d-%02d-%02dT%02d:%02d:%02d", 
    t.tm_year + 1900, t.tm_mon + 1, t.tm_mday, t.tm_hour, t.tm_min, t.tm_sec);
}

std::string DateFormats::formatDateTime(tm t) {
  char buffer[24];
  formatDateTime(t, buffer, 24);
  return std::string(buffer);
}
