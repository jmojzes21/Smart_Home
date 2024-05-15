
#pragma once

#include <ArduinoJson.h>

#include "core/leds.h"

extern LEDs leds;

class ColorPattern {

    protected:

    Color* colors = nullptr;
    int ledCount = 0;

    public:

    ColorPattern() {
        colors = leds.colors();
        ledCount = leds.ledCount();
    }

    virtual void setup() {}
    virtual void loop() {}
    virtual bool update(JsonObject p) { return true; }
    virtual void dispose() {}

};
