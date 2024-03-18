
#pragma once

#include <AsyncUDP.h>

#include "patterns/base_pattern.h"

#define LED_COUNT 7
#define LED_DATA_PIN 26

class LedManager {

    private:

    SemaphoreHandle_t _mutex;

    bool _directAccess = false;
    AsyncUDP _udp;

    const int _ledCount = LED_COUNT;
    CRGB _leds[LED_COUNT];
    BasePattern* _currentPattern = nullptr;

    public:

    void setup();
    void loop();

    bool updatePattern(JsonObject json);
    void setBrightness(uint8_t value);

    bool enableDirectAccess();

    private:

    bool _changePattern(JsonObject json);
    bool _updatePattern(JsonObject json);

    bool _enableDirectAccess();
    void _onUdpPacket(AsyncUDPPacket& packet);

    BasePattern* _createPattern(std::string& name);

};
