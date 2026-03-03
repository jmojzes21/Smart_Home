
#pragma once

#include <Arduino.h>
#include <string>
#include <Ticker.h>

class Device {

    public:
    
    std::string name = "";
    std::string password = "";
    std::string uuid = "";

    const char* version = nullptr;
    const char* deviceType = nullptr;
    const char* domain = nullptr;

    private:

    Ticker _restartTicker;

    public:

    void restart(int ms);

};
