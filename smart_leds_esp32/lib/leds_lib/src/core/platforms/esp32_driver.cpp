
#ifdef ESP32

#include "esp32_driver.h"
#include <FastLED.h>

#define LED_DATA_PIN 26

Esp32Driver::Esp32Driver() {}

void Esp32Driver::init() {

  CRGB* data = (CRGB*)colors();

  FastLED.addLeds<WS2812B, LED_DATA_PIN, GRB>(data, ledCount());
  FastLED.clear(true);

  FastLED.setMaxPowerInVoltsAndMilliamps(5, 300);
  FastLED.setBrightness(51);

}

void Esp32Driver::show() {
  FastLED.show();
}

void Esp32Driver::setBrightness(uint8_t value) {
  FastLED.setBrightness(value);
  FastLED.show();
}

void Esp32Driver::dispose() {}

#endif
