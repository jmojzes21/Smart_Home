
#define WIN32_LEAN_AND_MEAN
#include <Windows.h>
#include <chrono>

#include "leds/core/led_driver.h"
#include "leds/core/colors.h"

#include "leds/patterns/color_pattern.h"

#include "leds/patterns/single_color.h"
#include "leds/patterns/wave.h"
#include "leds/patterns/rainbow.h"
#include "leds/patterns/rainbow_balls.h"
#include "leds/patterns/rain.h"
#include "leds/patterns/rain_single.h"

LedDriver ledDriver;
std::chrono::steady_clock::time_point _startTimePoint;

static void start() {

    const char* ipAddress = "192.168.8.108";
    int port = 7000;

    srand(time(NULL));
    ledDriver.init(ipAddress, port);

    ColorPattern* pattern = new RainbowBallsPattern();

    while (true) {

        if (GetAsyncKeyState(VK_ESCAPE)) break;

        pattern->loop();
    }

    pattern->dispose();
    delete pattern;

}

int main() {
    start();
    return 0;
}

uint64_t micros() {

    auto now = std::chrono::high_resolution_clock::now();
    auto elapsed = now - _startTimePoint;

    uint64_t us = std::chrono::duration_cast<std::chrono::microseconds>(elapsed).count();
    return us;
}
