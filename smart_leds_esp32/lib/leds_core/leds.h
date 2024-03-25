
#pragma once

#ifdef ESP32

#include <FastLED.h>

#define LED_DATA_PIN 26

#endif

#include "color.h"
#include "colors.h"

#define LED_COUNT 7

class LEDs {

    private:

    Color _colors[LED_COUNT];
    int _ledCount = LED_COUNT;

    public:

    void setup();
    void show();
    void showColor(Color color);

    Color* colors();
    int ledCount();

};
