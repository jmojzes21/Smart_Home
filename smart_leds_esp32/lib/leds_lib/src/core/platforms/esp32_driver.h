#pragma once

#ifdef ESP32

#include <inttypes.h>
#include "core/led_driver.h"
#include "core/color.h"

class Esp32Driver : public ILedDriver {

public:

    Esp32Driver();

    void init() override;
    void show() override;
    void setBrightness(uint8_t value) override;
    void dispose() override;

};

#endif
