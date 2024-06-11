
#include "timer.h"

#ifdef _WIN32
uint32_t millis();
#endif

Timer::Timer() {
    _start = millis();
}

void Timer::setPeriod(uint32_t period) {
    _period = period;
}

bool Timer::run() {

    uint32_t now = millis();

    if (now - _start >= _period) {
        _start = now;
        return true;
    }

    return false;
}
