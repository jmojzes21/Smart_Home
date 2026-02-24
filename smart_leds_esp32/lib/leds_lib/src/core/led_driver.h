
#pragma once

#include "color.h"

#define LED_COUNT 7

class ILedDriver {

private:

    Color _colors[LED_COUNT];
    int _ledCount = LED_COUNT;

public:

    virtual void init() = 0;
    virtual void show() = 0;
    virtual void setBrightness(uint8_t value) = 0;
    
    void showColor(Color color);
    void clear();

    Color* colors();
    int ledCount();
    
    virtual void dispose() = 0;
    virtual ~ILedDriver();

};
