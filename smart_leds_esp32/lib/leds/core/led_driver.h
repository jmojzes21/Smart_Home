
#pragma once

#include "color.h"

#define LED_COUNT 7

class LedDriver {

private:

    Color _colors[LED_COUNT];
    int _ledCount = LED_COUNT;

public:

#ifdef ESP32
    void init(int dataPin);
#elif _WIN32
    void init();
#else
#error Unsupported platform
#endif

    void show();
    void showColor(Color color);

    void setBrightness(uint8_t value);
    void clear();

    Color* colors();
    int ledCount();

};
