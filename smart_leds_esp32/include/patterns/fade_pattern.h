
#pragma once

#include "base_pattern.h"

class FadePattern : public BasePattern {

    public:

    FadePattern(CRGB* leds, int ledCount) : BasePattern(leds, ledCount) {}

    void setup() override {
        
    }

    void loop() override {
        leds[0] == CRGB::Blue;
        FastLED.show();
    }

    bool update(JsonObject& p) override {
        return true;
    }

    void dispose() override {

    }

};
