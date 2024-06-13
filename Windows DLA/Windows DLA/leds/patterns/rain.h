
#pragma once

#include "color_pattern.h"

class RainDroplet {

public:

    float x = 0;

    bool visible = false;
    Color targetColor = Colors::Black;
    Color actualColor = Colors::Black;

    RainDroplet() {}

    void spawn(Color color) {
        visible = true;
        targetColor = color;
        actualColor = Colors::Black;
        x = 0;
    }

    void despawn() {
        x = 0;
        visible = false;
        actualColor = Colors::Black;
    }

    void loop() {

        if (!visible) return;

        actualColor = utils::scaleColor(targetColor, x);

        if (x < 0.2 || x >= 0.8) {
            x += 0.0005;
        }
        else {
            x += 0.002;
        }

        if (x >= 1) {
            despawn();
            return;
        }

    }

};

class RainPattern : public ColorPattern {

public:

    Color color = Colors::Black;
    bool useMultipleColors = false;

    std::vector<Color> basicColors;
    std::vector<RainDroplet> droplets;

    Timer spawnDropletsTimer;
    Timer dropletLoopTimer;

    RainPattern() {

        useMultipleColors = true;
        color = Colors::Blue;

        spawnDropletsTimer.setPeriod(2000);
        dropletLoopTimer.setPeriod(20);

        //

        utils::getBasicColors(basicColors);

        for (int i = 0; i < ledCount; i++) {
            droplets.push_back(RainDroplet());
        }
    }

    void showDroplets() {

        for (int i = 0; i < ledCount; i++) {
            leds[i] = droplets[i].actualColor;
        }

        ledDriver.show();

    }

    void spawnDroplet() {

        for (int i = 0; i < ledCount; i++) {

            int p = utils::getRandomNumber(ledCount);

            if (droplets[p].visible == false) {

                Color color;

                if (useMultipleColors) {
                    color = utils::getRandomColor(basicColors);
                }
                else {
                    color = this->color;
                }

                droplets[p].spawn(color);

                return;
            }

        }

    }

    void loop() override {
        
        if (spawnDropletsTimer.run()) {
            spawnDroplet();
        }

        if (dropletLoopTimer.run()) {
            
            for (int i = 0; i < ledCount; i++) {
                droplets[i].loop();
            }

            showDroplets();
        }

    }

    bool update(JsonObject p) override {
        
        bool multipleColors = p["multipleColors"];

        useMultipleColors = multipleColors;

        return true;
    }

};
