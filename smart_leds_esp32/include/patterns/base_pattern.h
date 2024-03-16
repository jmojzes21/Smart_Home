
#pragma once

#include <FastLED.h>
#include <ArduinoJson.h>

class BasePattern {

    protected:

    CRGB* leds = nullptr;
    int ledCount = 0;

    public:

    BasePattern(CRGB* leds, int ledCount) {
        this->leds = leds;
        this->ledCount = ledCount;
    }

    virtual void setup() {}
    virtual void loop() {}
    virtual void update(JsonObject p) {}
    virtual void dispose() {}

};
