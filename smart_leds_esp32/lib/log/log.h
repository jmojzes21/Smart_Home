
#pragma once

#include <Arduino.h>
#include <string>

#define qlog(format, ...) qlog_write("[%u] " format "\n", millis(), ##__VA_ARGS__)

void qlog_setup(size_t capacity);

void qlog_write(const char* format, ...);
std::string qlog_get_logs();

void qlog_clear();
