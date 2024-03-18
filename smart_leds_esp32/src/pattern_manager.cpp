
#include "pattern_manager.h"

#include "patterns/base_pattern.h"
#include "patterns/solid_color.h"
#include "patterns/fade_pattern.h"

#include "log.h"

void PatternManager::setup() {

    _mutex = xSemaphoreCreateMutex();

    FastLED.addLeds<WS2812B, LED_DATA_PIN, GRB>(_leds, LED_COUNT);
    FastLED.clear(true);
    
    FastLED.setBrightness(80);

    _udp.onPacket([&](AsyncUDPPacket packet) {
        _onUdpPacket(packet);
    });

}

void PatternManager::loop() {

    xSemaphoreTake(_mutex, portMAX_DELAY);

    if(_currentPattern != nullptr) {
        _currentPattern->loop();
    }
    
    xSemaphoreGive(_mutex);

}

void PatternManager::updatePattern(JsonObject json) {

    xSemaphoreTake(_mutex, portMAX_DELAY);

    if(_directAccess == false) {

        if(json.containsKey("name")) {
            _changePattern(json);
        }else{
            _updatePattern(json);
        }

    }
    
    xSemaphoreGive(_mutex);

}

void PatternManager::setBrightness(uint8_t value) {

    xSemaphoreTake(_mutex, portMAX_DELAY);

    if(_directAccess == false) {
        if(value > 80) value = 80;
        FastLED.setBrightness(value);
    }
    
    xSemaphoreGive(_mutex);

}

void PatternManager::enableDirectAccess() {

    xSemaphoreTake(_mutex, portMAX_DELAY);

    _enableDirectAccess();
    
    xSemaphoreGive(_mutex);

}

void PatternManager::_changePattern(JsonObject json) {

    std::string name = json["name"];

    BasePattern* newPattern = _createPattern(name);
    if(newPattern == nullptr) return;

    newPattern->setup();
    newPattern->update(json);

    if(_currentPattern != nullptr) {
        _currentPattern->dispose();
        delete _currentPattern;
    }

    _currentPattern = newPattern;
    
}

void PatternManager::_updatePattern(JsonObject json) {
    
    if(_currentPattern == nullptr);

    _currentPattern->update(json);

}

void PatternManager::_enableDirectAccess() {

    if(_directAccess) return;

    if(_currentPattern != nullptr) {
        _currentPattern->dispose();
        delete _currentPattern;
        _currentPattern = nullptr;
    }

    FastLED.clear(true);

    _udp.listen(7000);
    _directAccess = true;

}

void PatternManager::_onUdpPacket(AsyncUDPPacket& packet) {

    uint8_t* data = packet.data();
    int length = packet.length();

    xSemaphoreTake(_mutex, portMAX_DELAY);
    
    if(_directAccess) {

        uint8_t cmd = data[0];
        switch (cmd) {
            case 10:
                if(length >= sizeof(_leds) + 1) {
                    memcpy(_leds, data + 1, sizeof(_leds));
                    FastLED.show();
                }
                break;
            case 20:
                FastLED.clear(true);
                break;
        }

    }

    xSemaphoreGive(_mutex);

}

BasePattern* PatternManager::_createPattern(std::string& name) {

    if(name == "solid") {
        return new SolidColorPattern(_leds, _ledCount);
    }else if(name == "fade") {
        return new FadePattern(_leds, _ledCount);
    }

    return nullptr;
}
