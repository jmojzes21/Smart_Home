
#pragma once

#include <AsyncUDP.h>

#include "patterns/base_pattern.h"
#include "leds.h"

extern LEDs leds;

class LedManager {

    private:

    SemaphoreHandle_t _mutex;

    bool _directAccess = false;
    AsyncUDP _udp;

    BasePattern* _currentPattern = nullptr;

    public:

    void setup();
    void loop();

    bool updatePattern(JsonObject json);
    void setBrightness(uint8_t value);

    bool enableDLA();

    private:

    bool _changePattern(JsonObject json);
    bool _updatePattern(JsonObject json);

    bool _enableDLA();
    void _onUdpPacket(AsyncUDPPacket& packet);

    BasePattern* _createPattern(std::string& name);

};
