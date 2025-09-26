
#include "led_driver.h"

#include "platforms/platform_driver.h"

#ifdef ESP32

void LedDriver::init() {
    platform_led_driver::init(_colors, _ledCount);
}

#elif _WIN32

void LedDriver::init(const char* ipAddress, int port) {
    platform_led_driver::init(_colors, _ledCount, ipAddress, port);
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
    for (int i = 0; i < _ledCount; i++) {
        _colors[i] = 0;
    }
}

Color* LedDriver::colors() {
    return _colors;
}

int LedDriver::ledCount() {
    return _ledCount;
}

#ifdef _WIN32

LedDriver::~LedDriver() {
    platform_led_driver::dispose();
}

#endif
