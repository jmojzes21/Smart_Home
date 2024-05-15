
#pragma once

#include <ArduinoJson.h>

#include "core/led_driver.h"
#include "core/colors.h"

extern LedDriver ledDriver;

class ColorPattern {

    protected:

    Color* colors = nullptr;
    int ledCount = 0;

    public:

    ColorPattern() {
        colors = ledDriver.colors();
        ledCount = ledDriver.ledCount();
    }

    virtual void setup() {}
    virtual void loop() {}
    virtual bool update(JsonObject p) { return true; }
    virtual void dispose() {}

};
