
#pragma once

#include <inttypes.h>

class Timer {

private:

    uint64_t _period;
    uint64_t _start;
    uint64_t _rawProgress;

public:

    Timer();

    void setPeriod(uint32_t periodMillis);
    void reset();
    float getProgress();

    bool run();

};
