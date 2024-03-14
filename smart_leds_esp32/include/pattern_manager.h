
#pragma once

#include "patterns/base_pattern.h"

#define LED_COUNT 7
#define LED_DATA_PIN 26

class PatternManager {

    public:

    const int ledCount = LED_COUNT;
    CRGB leds[LED_COUNT];
    BasePattern* currentPattern = nullptr;

    void setup();
    void loop();

    bool changePattern(JsonObject& pattern);
    bool updatePattern(JsonObject& pattern);

    private:

    BasePattern* _createPattern(std::string& name);

};
