
#include "platform_driver.h"

#ifdef ESP32

#include <FastLED.h>

#define LED_DATA_PIN 26

namespace platform_led_driver {

    void init(Color* colors, int ledCount) {

        CRGB* data = (CRGB*)colors;

        FastLED.addLeds<WS2812B, LED_DATA_PIN, GRB>(data, ledCount);
        FastLED.clear(true);

        FastLED.setBrightness(80);

    }

    void show() {
        FastLED.show();
    }

    void setBrightness(uint8_t value) {

        if (value > 80) value = 80;

        FastLED.setBrightness(value);
        FastLED.show();

    }

}

#endif
