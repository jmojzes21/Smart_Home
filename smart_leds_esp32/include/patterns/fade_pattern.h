
#pragma once

#include "base_pattern.h"

class FadePattern : public BasePattern {

    public:

    CRGB color;
    bool value = true;

    FadePattern(CRGB* leds, int ledCount) : BasePattern(leds, ledCount) {}

    void setup() override {
        color = CRGB::Black;
    }

    void loop() override {

        EVERY_N_MILLIS(500) {
            value = !value;
            if(value) {
                FastLED.showColor(color);
            }else{
                FastLED.showColor(CRGB::Black);
            }
            
        }
        
    }

    bool update(JsonObject p) override {
        int rgb = p["color"];
        color = CRGB(rgb);
        return true;
    }

    void dispose() override {

    }

};
