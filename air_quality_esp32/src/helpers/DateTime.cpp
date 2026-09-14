
#include "helpers/DateTime.h"

#include <stdio.h>
#include <cstdlib>

void DateTime::setDate(uint8_t weekday, uint8_t day, uint8_t month, uint16_t year) {
  this->weekday = weekday;
  this->day = day;
  this->month = month;
  this->year = year;
}

void DateTime::setTime(uint8_t hour, uint8_t minute, uint8_t second) {
  this->hour = hour;
  this->minute = minute;
  this->second = second;
}

std::string DateTime::toString() {
  char buffer[24];
  snprintf(buffer, 24, "%04d-%02d-%02dT%02d:%02d:%02d", year, month, day, hour, minute, second);
  return std::string(buffer);
}

bool DateTime::fromString(std::string& input, DateTime* time) {
  std::string data = input;

  for(int i = 0; i < data.length(); i++) {
    char c = data[i];
    switch(c) {
      case 'T':
      case ':':
        data[i] = '-';
        break;
    }
  }

  int values[6];
  size_t start = 0;
  size_t end = 0;

  for(int i = 0; i < 5; i++) {
    end = data.find('-', start);
    if(end == -1) return false;

    data[end] = 0;
    values[i] = std::atoi(&data[start]);

    start = end + 1;
    if(start >= data.length()) return false;
  }

  values[5] = std::atoi(&data[start]);

  int year = values[0];
  int month = values[1];
  int day = values[2];
  int hour = values[3];
  int minute = values[4];
  int second = values[5];

  if(year < 1900) return false;
  if(not(month >= 1 && month <= 12)) return false;
  if(not(day >= 1 && day <= 31)) return false;
  if(not(hour >= 0 && hour < 24)) return false;
  if(not(minute >= 0 && minute < 60)) return false;
  if(not(second >= 0 && second < 60)) return false;

  time->setDate(0, day, month, year);
  time->setTime(hour, minute, second);

  return true;
}
