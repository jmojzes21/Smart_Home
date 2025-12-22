
#pragma once

#include "color_pattern.h"

class SingleColorPattern : public ColorPattern {

public:

    Color oldColor = Colors::Black;
    Color newColor = Colors::Black;

    Color actualColor = Colors::Black;

    bool inAnimation = false;
    Timer animationTimer;

    SingleColorPattern() {
        animationTimer.setPeriod(400);
    }

    void loop() override {
        
        if (inAnimation) {

            if (animationTimer.run()) {
                inAnimation = false;
            }

            float p = animationTimer.getProgress();

            actualColor = utils::lerpColor(oldColor, newColor, p);
            ledDriver.showColor(actualColor);
            
        }
    
    }

    bool update(JsonObject p) override {

        int color = p["color"];
        
        if (actualColor == Colors::Black) {
            
            actualColor = color;
            newColor = color;

            ledDriver.showColor(actualColor);

            inAnimation = false;
            return true;
        }

        oldColor = actualColor;
        newColor = color;

        inAnimation = true;
        animationTimer.reset();

        return true;
    }

};
