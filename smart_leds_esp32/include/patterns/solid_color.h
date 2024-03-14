
#pragma once

#include "base_pattern.h"

class SolidColorPattern : public BasePattern {

    public:

    SolidColorPattern(CRGB* leds, int ledCount) : BasePattern(leds, ledCount) {}

    void setup() override {
        
    }

    void loop() override {
        leds[0] == CRGB::Green;
        FastLED.show();
    }

    bool update(JsonObject& p) override {
        return true;
    }

    void dispose() override {

    }

};
