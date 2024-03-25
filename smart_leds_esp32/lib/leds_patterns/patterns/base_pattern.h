
#pragma once

#include <ArduinoJson.h>

#include "leds.h"

extern LEDs leds;

class BasePattern {

    protected:

    Color* colors = nullptr;
    int ledCount = 0;

    public:

    BasePattern() {
        colors = leds.colors();
        ledCount = leds.ledCount();
    }

    virtual void setup() {}
    virtual void loop() {}
    virtual bool update(JsonObject p) { return true; }
    virtual void dispose() {}

};
