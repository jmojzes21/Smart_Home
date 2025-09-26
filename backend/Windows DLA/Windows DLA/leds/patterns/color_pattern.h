
#pragma once

#include <ArduinoJson.h>

#include "core/led_driver.h"
#include "core/colors.h"
#include "core/color_utils.h"
#include "core/timer.h"

extern LedDriver ledDriver;

class ColorPattern {

    protected:

    Color* leds = nullptr;
    int ledCount = 0;

    public:

    ColorPattern() {
        leds = ledDriver.colors();
        ledCount = ledDriver.ledCount();
    }

    virtual void loop() {}
    virtual bool update(JsonObject p) { return true; }
    virtual void dispose() {}

};
