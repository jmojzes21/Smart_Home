
#include "dasduino_led.h"

#ifdef ESP32
#define LED_DATA_PIN 32
#else
#error "Unknown board"
#endif

DasduinoLed::DasduinoLed() {
  _ledController = nullptr;
  _brightness = 255;
}

void DasduinoLed::begin() {
  _ledController = &FastLED.addLeds<WS2812B, LED_DATA_PIN, GRB>(_leds, 1);
  _ledController->clearLeds();
}

void DasduinoLed::setBrightness(uint8_t brightness) {
  _brightness = brightness;
  _ledController->show(_leds, 1, _brightness);
}

uint8_t DasduinoLed::getBrightness() {
  return _brightness;
}

void DasduinoLed::showColor(CRGB color) {
  _leds[0] = color;
  _ledController->show(_leds, 1, _brightness);
}

void DasduinoLed::turnOff() {
  _ledController->clearLeds();
}

CRGB DasduinoLed::getColor() {
  return _leds[0];
}
