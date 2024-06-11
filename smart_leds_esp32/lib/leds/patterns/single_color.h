
#pragma once

#include "color_pattern.h"

class SingleColorPattern : public ColorPattern {

public:

    Color color = Colors::Black;

    SingleColorPattern() {}

    void loop() override {}

    bool update(JsonObject p) override {

        int rgb = p["color"];
        color = rgb;

        ledDriver.showColor(color);

        return true;
    }

    void dispose() override {}

};
