
#pragma once

#include "color_pattern.h"

class WavePattern : public ColorPattern {

public:

    Color color = Colors::Black;
    uint16_t speed = 0;
    float x = 0;

    Timer speedTimer;

    WavePattern() {}

    void preview() override {
        color = Colors::Purple;
        speed = 15;

        speedTimer.setPeriod(speed);
    }

    void loop() override {
        
        if (speedTimer.run()) {

            x += 0.01;
            if (x >= M_PI) {
                x = 0;
            }

            float value = 0.95 * sinf(x) + 0.05;

            float r = value * (float)color.r;
            float g = value * (float)color.g;
            float b = value * (float)color.b;

            Color actualColor = Color(r, g, b);
            ledDriver.showColor(actualColor);

        }

    }

    bool update(JsonObject p) override {

        int rgb = p["color"];
        uint16_t speed = p["speed"];

        this->color = rgb;
        this->speed = speed;

        return true;
    }

    void dispose() override {}

};
