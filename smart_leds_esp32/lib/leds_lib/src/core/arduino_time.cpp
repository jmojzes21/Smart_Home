
#ifdef _WIN32

#include "arduino_time.h"

#include <chrono>

namespace ArduinoTime {
    
    std::chrono::steady_clock::time_point _startTimePoint;

    void init() {
        _startTimePoint = std::chrono::high_resolution_clock::now();
    }

}

uint64_t micros() {

    auto now = std::chrono::high_resolution_clock::now();
    auto elapsed = now - ArduinoTime::_startTimePoint;

    uint64_t us = std::chrono::duration_cast<std::chrono::microseconds>(elapsed).count();
    return us;
}

#endif
