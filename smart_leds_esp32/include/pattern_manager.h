
#pragma once

#include <AsyncUDP.h>

#include "patterns/base_pattern.h"

#define LED_COUNT 7
#define LED_DATA_PIN 26

class PatternManager {

    private:

    SemaphoreHandle_t _mutex;

    uint8_t _updateCode = 0;
    JsonDocument _patternJson;
    uint8_t _brightness;

    bool _directAccess = false;
    AsyncUDP _udp;

    const int _ledCount = LED_COUNT;
    CRGB _leds[LED_COUNT];
    BasePattern* _currentPattern = nullptr;

    public:

    void setup();
    void loop();

    void updatePattern(JsonVariant& json);
    void setBrightness(int value);

    void enableDirectAccess();

    private:

    void _handleUpdate();

    void _changePattern();
    void _updatePattern();

    void _enableDirectAccess();
    void _onUdpPacket(AsyncUDPPacket& packet);

    BasePattern* _createPattern(std::string& name);

};
