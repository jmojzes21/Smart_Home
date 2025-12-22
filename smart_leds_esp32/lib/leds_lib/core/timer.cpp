
#include "timer.h"

#ifdef ARDUINO
#include <Arduino.h>
#elif _WIN32
uint64_t micros();
#endif

Timer::Timer() {
    reset();
}

void Timer::setPeriod(uint32_t periodMillis) {
    _period = periodMillis * 1000;
}

void Timer::reset() {
    _start = micros();
    _rawProgress = 0;
}

bool Timer::run() {

    uint64_t now = micros();
    _rawProgress = now - _start;

    if (_rawProgress >= _period) {
        _start = now;
        return true;
    }

    return false;
}

float Timer::getProgress() {
    float p = (float)_rawProgress / (float)_period;
    if (p > 1) p = 1;

    return p;
}
