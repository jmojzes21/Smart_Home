
#pragma once

#include "color_pattern.h"

class SolidColorPattern : public ColorPattern {

    public:

    Color color;

    SolidColorPattern() {}

    void setup() override {
        color = Colors::Black;
        ledDriver.show();
    }

    void loop() override {
        
    }

    bool update(JsonObject p) override {
        int rgb = p["color"];
        color = Color(rgb);
        ledDriver.showColor(color);
        return true;
    }

    void dispose() override {

    }

};
