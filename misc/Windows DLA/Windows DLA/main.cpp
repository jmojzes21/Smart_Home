
#define WIN32_LEAN_AND_MEAN
#include <Windows.h>
#include <iostream>
#include <ctime>

#include "core/led_driver.h"
#include "core/colors.h"

#include "patterns/color_pattern.h"
#include "patterns/single_color.h"
#include "patterns/wave.h"
#include "patterns/rainbow.h"
#include "patterns/rainbow_balls.h"
#include "patterns/rain.h"

#include "core/platforms/win_dla_driver.h"
#include "core/arduino_time.h"

void start(const char* ipAddress, int port) {
    
    ArduinoTime::init();

    ILedDriver* ledDriver = new WinDlaDriver(ipAddress, port);

    srand(time(NULL));
    ledDriver->init();

    ColorPattern* pattern = new RainbowPattern(ledDriver);

    JsonDocument doc;
    doc["color"] = 0x0000FF;
    doc["multipleColors"] = true;
    doc["speed"] = 20;

    pattern->update(doc.as<JsonObject>());

    while (true) {

        if (GetAsyncKeyState(VK_ESCAPE)) break;

        pattern->loop();
    }

    pattern->dispose();
    delete pattern;

    ledDriver->dispose();
    delete ledDriver;

}


int main(int argc, char* argv[]) {

    if (argc != 3) {
        printf("Usage [ip address] [port]\n");
        std::cin.get();
        return -1;
    }

    const char* ipAddress = argv[1];
    int port = atoi(argv[2]);

    start(ipAddress, port);
    return 0;
}
