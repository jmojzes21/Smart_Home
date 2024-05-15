
#pragma once

#include "color_pattern.h"

class FadePattern : public ColorPattern {

    public:

    Color color;
    bool value = true;

    FadePattern() {}

    void setup() override {
        color = Colors::Black;
        ledDriver.show();
    }

    void loop() override {
        
    }

    bool update(JsonObject p) override {
        int rgb = p["color"];
        color = Color(rgb);
        return true;
    }

    void dispose() override {

    }

};
