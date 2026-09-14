
#pragma once

#include <inttypes.h>
#include <string>

class DateTime {

  public:

  uint16_t year = 0;
  uint8_t month = 0;
  uint8_t day = 0;
  uint8_t weekday = 0;

  uint8_t hour = 0;
  uint8_t minute = 0;
  uint8_t second = 0;

  DateTime() {}

  void setDate(uint8_t weekday, uint8_t day, uint8_t month, uint16_t year);
  void setTime(uint8_t hour, uint8_t minute, uint8_t second);

  std::string toString();

  static bool fromString(std::string& input, DateTime* time);

};
