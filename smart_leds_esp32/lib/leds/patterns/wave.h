
#pragma once

#include "color_pattern.h"

class WavePattern : public ColorPattern {

public:

    Color color = Colors::Black;
    float x = 0;

    std::vector<Color> basicColors;
    bool changeColors = false;

    Timer speedTimer;

    WavePattern() {
        utils::getBasicColors(basicColors);
    }

    void loop() override {
        
        if (speedTimer.run()) {

            x += 0.01;
            if (x >= M_PI) {
                x = 0;

                if (changeColors) {
                    color = utils::getRandomColor(basicColors);
                }
            }

            float value = sinf(x);

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
        bool changeColors = p["changeColors"];

        this->color = rgb;
        this->changeColors = changeColors;
        speedTimer.setPeriod(speed);

        return true;
    }

};
