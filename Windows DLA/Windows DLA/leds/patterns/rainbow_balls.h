
#pragma once

#include "color_pattern.h"

class RainbowBallsPattern : public ColorPattern {

public:

    uint8_t hue = 0;
    Timer speedTimer;

    RainbowBallsPattern() {
        speedTimer.setPeriod(20);
    }

    void loop() override {

        if (speedTimer.run()) {

            uint8_t tempHue = hue;

            leds[0] = Colors::Black;
            for (int i = 1; i < ledCount; i++) {
                leds[i] = utils::getRainbowColor(tempHue);
                tempHue += 42;
            }

            ledDriver.show();

            hue++;
        }

    }

    bool update(JsonObject p) override {

        int speed = p["speed"];
        speedTimer.setPeriod(speed);

        return true;
    }

};
