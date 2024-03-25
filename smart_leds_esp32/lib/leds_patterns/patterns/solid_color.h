
#pragma once

#include "base_pattern.h"

class SolidColorPattern : public BasePattern {

    public:

    Color color;

    SolidColorPattern() {}

    void setup() override {
        color = Colors::Black;
        leds.show();
    }

    void loop() override {
        EVERY_N_MILLIS(200) {
            leds.showColor(color);
        }
    }

    bool update(JsonObject p) override {
        int rgb = p["color"];
        color = Color(rgb);
        leds.showColor(color);
        return true;
    }

    void dispose() override {

    }

};
