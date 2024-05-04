
#pragma once

#include <Arduino.h>
#include <string>
#include <Ticker.h>

const bool useRealHardware = false;

class Device {

    public:
    
    std::string name = "";
    std::string password = "";

    const char* version = nullptr;
    const char* deviceType = nullptr;

    private:

    Ticker _restartTicker;

    public:

    void restart(int ms);

};
