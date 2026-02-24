
#include "led_driver.h"

void ILedDriver::showColor(Color color) {

    for (int i = 0; i < _ledCount; i++) {
        _colors[i] = color;
    }

    show();

}

void ILedDriver::clear() {
    for (int i = 0; i < _ledCount; i++) {
        _colors[i] = 0;
    }
}

Color* ILedDriver::colors() {
    return _colors;
}

int ILedDriver::ledCount() {
    return _ledCount;
}

ILedDriver::~ILedDriver() {}
