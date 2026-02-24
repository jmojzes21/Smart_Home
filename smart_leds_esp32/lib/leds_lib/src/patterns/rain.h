
#pragma once

#include "color_pattern.h"

class RainDroplet {

public:

    float x = 0;
    float hue = 0;

    bool isFalling = false;
    bool useMultipleColors = false;

    Color targetColor;
    Color actualColor;

    RainDroplet() {}
    
    void setSingleColorMode(Color color) {
        useMultipleColors = false;

        if (!isFalling) actualColor = color;
        targetColor = color;
    }

    void setMultipleColorsMode() {
        useMultipleColors = true;

        Color color = utils::getRainbowColor(hue);

        if (!isFalling) actualColor = color;
        targetColor = color;
    }

    void fall() {
        isFalling = true;
        actualColor = targetColor;
        x = 0;
    }

    void loop() {

        if (isFalling) {

            if (useMultipleColors) {
                targetColor = utils::getRainbowColor(hue);
                hue += 0.2;
                if (hue >= 256) hue = 0;
            }
            
            float scale = 1.0 - sin(x);
            actualColor = utils::scaleColor(targetColor, scale);

            x += 0.008;
            if (x >= M_PI) {
                isFalling = false;
                actualColor = targetColor;
            }

        }

    }

};

class RainPattern : public ColorPattern {

public:

    std::vector<RainDroplet> droplets;

    Timer msTimer;
    Timer rainTimer;

    RainPattern(ILedDriver* ledDriver) : ColorPattern(ledDriver) {

        msTimer.setPeriod(2);
        rainTimer.setPeriod(200);

        for (int i = 0; i < ledCount; i++) {
            droplets.push_back(RainDroplet());
        }

    }

    void startDropletFall() {
        for (int i = 0; i < ledCount; i++) {

            int p = utils::getRandomNumber(ledCount);

            if (!droplets[p].isFalling) {
                droplets[p].fall();
                return;
            }

        }
    }

    void loop() override {

        if (rainTimer.run()) {
            startDropletFall();
        }

        if (msTimer.run()) {
            
            for (int i = 0; i < ledCount; i++) {
                droplets[i].loop();
                leds[i] = droplets[i].actualColor;
            }

            ledDriver->show();

        }

    }

    bool update(JsonObject p) override {
        
        int rgb = p["color"];
        bool multipleColors = p["multipleColors"];

        for (int i = 0; i < ledCount; i++) {
            RainDroplet& droplet = droplets[i];

            if (multipleColors) {
                droplet.setMultipleColorsMode();
            } else {
                droplet.setSingleColorMode(rgb);
            }
        }

        return true;
    }

};
