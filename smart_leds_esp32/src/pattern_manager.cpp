
#include "pattern_manager.h"

#include "patterns/base_pattern.h"
#include "patterns/solid_color.h"
#include "patterns/fade_pattern.h"

#include "log.h"

#define UPDATE_CODE_DIRECT_ACCESS 1
#define UPDATE_CODE_PATTERN 2
#define UPDATE_CODE_BRIGHTNESS 3
#define UPDATE_CODE_ENABLE_DIRECT_ACCESS 4

#define LED_DATA_PAYLOAD_SIZE (LED_COUNT * 3)

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

    if(xSemaphoreTake(_mutex, portMAX_DELAY) == pdTRUE) {

        if(_updateCode != 0) {
            _handleUpdate();
        }

        if(_currentPattern != nullptr) {
            _currentPattern->loop();
        }
        
        xSemaphoreGive(_mutex);
    }

}

void PatternManager::updatePattern(JsonVariant& json) {

    if(xSemaphoreTake(_mutex, portMAX_DELAY) == pdTRUE) {
        
        if(_directAccess == false) {
            _updateCode = UPDATE_CODE_PATTERN;
            _patternJson = json;
        }
        
        xSemaphoreGive(_mutex);
    }

}

void PatternManager::setBrightness(int value) {

    if(xSemaphoreTake(_mutex, portMAX_DELAY) == pdTRUE) {

        if(_directAccess == false) {
            _updateCode = UPDATE_CODE_BRIGHTNESS;
            _brightness = value;
        }
        
        xSemaphoreGive(_mutex);
    }

}

void PatternManager::enableDirectAccess() {

    if(xSemaphoreTake(_mutex, portMAX_DELAY) == pdTRUE) {

        if(_directAccess == false) {
            _updateCode = UPDATE_CODE_ENABLE_DIRECT_ACCESS;
        }
        
        xSemaphoreGive(_mutex);
    }

}

void PatternManager::_handleUpdate() {

    switch (_updateCode) {

        case UPDATE_CODE_DIRECT_ACCESS:
            FastLED.show();
            break;

        case UPDATE_CODE_PATTERN:
            if(_patternJson.containsKey("name")) {
                _changePattern();
            }else{
                _updatePattern();
            }
            _patternJson.clear();

            break;

        case UPDATE_CODE_BRIGHTNESS:
            if(_brightness > 80) _brightness = 80;
            FastLED.setBrightness(_brightness);
            _brightness = 0;
            break;

        case UPDATE_CODE_ENABLE_DIRECT_ACCESS:
            _enableDirectAccess();
            break;

    }

    _updateCode = 0;

}

void PatternManager::_changePattern() {

    JsonObject p = _patternJson.as<JsonObject>();
    std::string name = p["name"];

    BasePattern* newPattern = _createPattern(name);
    if(newPattern == nullptr) return;

    newPattern->setup();
    newPattern->update(p);

    if(_currentPattern != nullptr) {
        _currentPattern->dispose();
        delete _currentPattern;
    }

    _currentPattern = newPattern;
    
}

void PatternManager::_updatePattern() {
    
    if(_currentPattern == nullptr);

    JsonObject p = _patternJson.as<JsonObject>();
    _currentPattern->update(p);

}

void PatternManager::_enableDirectAccess() {

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

    if(xSemaphoreTake(_mutex, portMAX_DELAY) == pdTRUE) {
        
        if(_directAccess && length >= sizeof(_leds)) {
            memcpy(_leds, data, sizeof(_leds));
            _updateCode = UPDATE_CODE_DIRECT_ACCESS;
        }

        xSemaphoreGive(_mutex);
    }

}

BasePattern* PatternManager::_createPattern(std::string& name) {

    if(name == "solid") {
        return new SolidColorPattern(_leds, _ledCount);
    }else if(name == "fade") {
        return new FadePattern(_leds, _ledCount);
    }

    return nullptr;
}
