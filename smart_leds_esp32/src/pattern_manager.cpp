
#include "pattern_manager.h"

#include "patterns/base_pattern.h"
#include "patterns/solid_color.h"
#include "patterns/fade_pattern.h"

void PatternManager::setup() {

    FastLED.addLeds<WS2812B, LED_DATA_PIN, GRB>(leds, LED_COUNT);
    FastLED.clear(true);
    
    FastLED.setBrightness(40);

}

void PatternManager::loop() {

    if(currentPattern != nullptr) {
        currentPattern->loop();
    }

}

bool PatternManager::changePattern(JsonObject& pattern) {

    std::string name = pattern["name"];
    if(name == "") return false;

    BasePattern* newPattern = _createPattern(name);
    if(newPattern == nullptr) return false;

    newPattern->setup();
    bool result = newPattern->update(pattern);

    if(result == false) {
        newPattern->dispose();
        delete newPattern;
        return false;
    }

    if(currentPattern != nullptr) {
        currentPattern->dispose();
        delete currentPattern;
    }

    currentPattern = newPattern;
    return true;
    
}

bool PatternManager::updatePattern(JsonObject& pattern) {
    
    if(currentPattern == nullptr) return false;

    return currentPattern->update(pattern);
}

BasePattern* PatternManager::_createPattern(std::string& name) {

    if(name == "solid") {
        return new SolidColorPattern(leds, ledCount);
    }else if(name == "fade") {
        return new FadePattern(leds, ledCount);
    }

    return nullptr;
}
