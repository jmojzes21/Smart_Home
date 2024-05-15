
#include <iostream>

#define WIN32_LEAN_AND_MEAN
#include <Windows.h>

#include "leds/core/led_driver.h"
#include "leds/core/colors.h"

LedDriver ledDriver;

int main() {
    
    const char* ipAddress = "192.168.8.108";
    int port = 7000;

    ledDriver.init(ipAddress, port);
    
    return 0;
}
