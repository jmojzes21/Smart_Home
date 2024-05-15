
#include "led_driver.h"

#include "platforms/platform_driver.h"

#ifdef ESP32

void LedDriver::init() {
    platform_led_driver::init(_colors, _ledCount);
}

#elif _WIN32

void LedDriver::init() {
    platform_led_driver::init();
}

#else
#error Unsupported platform
#endif

void LedDriver::show() {
    platform_led_driver::show();
}

void LedDriver::showColor(Color color) {

    for (int i = 0; i < _ledCount; i++) {
        _colors[i] = color;
    }

    platform_led_driver::show();

}

void LedDriver::setBrightness(uint8_t value) {
    platform_led_driver::setBrightness(value);
}

void LedDriver::clear() {
    platform_led_driver::clear();
}

Color* LedDriver::colors() {
    return _colors;
}

int LedDriver::ledCount() {
    return _ledCount;
}
