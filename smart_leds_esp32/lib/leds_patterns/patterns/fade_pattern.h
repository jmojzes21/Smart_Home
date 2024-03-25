
#pragma once

#include "color_pattern.h"

class FadePattern : public ColorPattern {

    public:

    Color color;
    bool value = true;

    FadePattern() {}

    void setup() override {
        color = Colors::Black;
        leds.show();
    }

    void loop() override {

        EVERY_N_MILLIS(500) {
            value = !value;
            if(value) {
                leds.showColor(color);
            }else{
                leds.showColor(Colors::Black);
            }
            
        }
        
    }

    bool update(JsonObject p) override {
        int rgb = p["color"];
        color = Color(rgb);
        return true;
    }

    void dispose() override {

    }

};
