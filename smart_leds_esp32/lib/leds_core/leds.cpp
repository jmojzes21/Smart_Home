
#include "leds.h"

void LEDs::setup() {

    #ifdef ESP32

    CRGB* data = (CRGB*)_colors;

    FastLED.addLeds<WS2812B, LED_DATA_PIN, GRB>(data, LED_COUNT);
    FastLED.clear(true);

    FastLED.setBrightness(80);

    #endif

}

void LEDs::clear() {
    
    #ifdef ESP32

    FastLED.clear(true);

    #endif

}

void LEDs::show() {

    #ifdef ESP32

    FastLED.show();

    #endif

}

void LEDs::showColor(Color color) {

    #ifdef ESP32

    CRGB crgb = CRGB(color.r, color.g, color.b);
    FastLED.showColor(crgb);

    #endif

}

void LEDs::setBrightness(uint8_t value) {

    #ifdef ESP32

    if(value > 80) value = 80;

    FastLED.setBrightness(value);
    FastLED.show();

    #endif

}

Color* LEDs::colors() {
    return _colors;
}

int LEDs::ledCount() {
    return _ledCount;
}
