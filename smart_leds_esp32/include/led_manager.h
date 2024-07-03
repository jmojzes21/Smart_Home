
#pragma once

#include <AsyncUDP.h>

#include "patterns/color_pattern.h"
#include "core/led_driver.h"

extern LedDriver ledDriver;

class LedManager {

    private:

    SemaphoreHandle_t _mutex;

    bool _directAccess = false;
    AsyncUDP _udp;

    ColorPattern* _currentPattern = nullptr;
    std::string _currentPatternName = "";

    public:

    void setup();
    void loop();

    bool updatePattern(JsonObject json);
    void clearPattern();
    void setBrightness(uint8_t value);

    void enableDLA();

    private:

    bool _changePattern(std::string& name, JsonObject json);
    bool _updatePattern(JsonObject json);
    void _clearPattern();

    void _enableDLA();
    void _disableDLA();
    void _onUdpPacket(AsyncUDPPacket& packet);

    ColorPattern* _createPattern(std::string& name);

};
