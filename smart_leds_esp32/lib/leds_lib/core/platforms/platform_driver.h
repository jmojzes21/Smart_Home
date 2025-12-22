
#pragma once

#include <inttypes.h>
#include "core/color.h"

namespace platform_led_driver {

#ifdef ESP32
    void init(Color* colors, int ledCount);
#elif _WIN32
    void init(Color* colors, int ledCount, const char* ipAddress, int port);
#else
#error Unsupported platform
#endif

    void show();
    void setBrightness(uint8_t value);

#ifdef _WIN32
    void dispose();
#endif

}
