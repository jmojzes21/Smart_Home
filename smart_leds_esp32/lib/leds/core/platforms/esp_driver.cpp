
#include "platform_driver.h"

#ifdef ESP32

#include <FastLED.h>

namespace platform_led_driver {

    void init(Color* colors, int dataPin) {

        CRGB* data = (CRGB*)_colors;

        FastLED.addLeds<WS2812B, dataPin, GRB>(data, LED_COUNT);
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

    void clear() {
        FastLED.clear(true);
    }

}

#endif
