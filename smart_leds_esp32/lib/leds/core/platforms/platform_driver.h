
#pragma once

#include <inttypes.h>

namespace platform_led_driver {

#ifdef ESP32
    void init(Color* colors, int dataPin);
#elif _WIN32
    void init();
#else
#error Unsupported platform
#endif

    void show();

    void setBrightness(uint8_t value);
    void clear();

}
