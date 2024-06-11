
#define WIN32_LEAN_AND_MEAN
#include <Windows.h>
#include <chrono>

#include "leds/core/led_driver.h"
#include "leds/core/colors.h"

#include "leds/patterns/color_pattern.h"

#include "leds/patterns/single_color.h"
#include "leds/patterns/wave.h"
#include "leds/patterns/rainbow.h"
#include "leds/patterns/rainbow_single.h"
#include "leds/patterns/rain.h"
#include "leds/patterns/rain_single.h"

LedDriver ledDriver;
std::chrono::steady_clock::time_point _startTimePoint;

int WINAPI WinMain(HINSTANCE hInstance, HINSTANCE hPrevInstance, PSTR lpCmdLine, int nCmdShow) {
    
    const char* ipAddress = "192.168.8.108";
    int port = 7000;

    ledDriver.init(ipAddress, port);
    
    ColorPattern* pattern = new WavePattern();
    pattern->preview();

    while (true) {

        if (GetAsyncKeyState(VK_ESCAPE)) break;

        pattern->loop();
        Sleep(1);
    }

    pattern->dispose();
    delete pattern;
    
    return 0;
}

uint32_t millis() {

    auto now = std::chrono::high_resolution_clock::now();
    auto elapsed = now - _startTimePoint;

    uint64_t ms = std::chrono::duration_cast<std::chrono::milliseconds>(elapsed).count();
    return ms;
}
