
#pragma once

#include <FastLED.h>

class DasduinoLed {

private:

  CLEDController* _ledController;
  CRGB _leds[1];

  uint8_t _brightness;

public:

  DasduinoLed();
  void begin();

  void setBrightness(uint8_t brightness);
  uint8_t getBrightness();

  void showColor(CRGB color);
  void turnOff();

  CRGB getColor();
  
};
