
#include "DasduinoLed.h"
#include <Adafruit_NeoPixel.h>

#ifdef ESP32
#define LED_DATA_PIN 32
#else
#error "Unknown board"
#endif

namespace DasduinoLed {

  static Adafruit_NeoPixel* _pixels = nullptr;

  void init() {
    if(_pixels != nullptr) return;

    _pixels = new Adafruit_NeoPixel(1, LED_DATA_PIN, NEO_GRB + NEO_KHZ800);
    _pixels->begin();
  }

  void setBrightness(uint8_t b) {
    if(_pixels == nullptr) return;

    _pixels->setBrightness(b);
  }

  void showColor(uint32_t color) {
    if(_pixels == nullptr) return;

    _pixels->setPixelColor(0, color);
    _pixels->show();
  }

  void clear() {
    if(_pixels == nullptr) return;

    _pixels->clear();
    _pixels->show();
  }

  uint32_t getRGB(uint8_t r, uint8_t g, uint8_t b) {
    return ((uint32_t)r << 16) | ((uint32_t)g << 8) | b;
  }

}
