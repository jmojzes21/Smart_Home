
#pragma once

#include "color_pattern.h"

class RainbowPattern : public ColorPattern {

public:

    uint8_t hue = 0;
    Timer speedTimer;

    RainbowPattern() {}

    void loop() override {
        
        if (speedTimer.run()) {

            Color color = utils::getRainbowColor(hue);
            ledDriver.showColor(color);

            hue++;
        }

    }

    bool update(JsonObject p) override {

        int speed = p["speed"];
        speedTimer.setPeriod(speed);

        return true;
    }

};
