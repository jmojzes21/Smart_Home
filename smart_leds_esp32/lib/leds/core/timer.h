
#pragma once

#include <inttypes.h>

class Timer {

private:

    uint32_t _period;
    uint32_t _start;

public:

    Timer();

    void setPeriod(uint32_t period);
    bool run();

};
