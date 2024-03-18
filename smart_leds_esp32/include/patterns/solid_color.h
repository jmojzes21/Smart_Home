
#pragma once

#include "base_pattern.h"

class SolidColorPattern : public BasePattern {

    public:

    CRGB color;

    SolidColorPattern(CRGB* leds, int ledCount) : BasePattern(leds, ledCount) {}

    void setup() override {
        color = CRGB::Black;
        FastLED.showColor(color);
    }

    void loop() override {
        EVERY_N_MILLIS(200) {
            FastLED.showColor(color);
        }
    }

    bool update(JsonObject p) override {
        int rgb = p["color"];
        color = CRGB(rgb);
        FastLED.showColor(color);
        return true;
    }

    void dispose() override {

    }

};
