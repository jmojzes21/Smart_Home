
#include "led_manager.h"

#include "patterns/color_pattern.h"
#include "patterns/solid_color.h"
#include "patterns/fade_pattern.h"

#include "log.h"

#define DLA_PAYLOAD_SIZE (sizeof(Color) * LED_COUNT)

void LedManager::setup() {

    _mutex = xSemaphoreCreateMutex();

    leds.setup();

    _udp.onPacket([&](AsyncUDPPacket packet) {
        _onUdpPacket(packet);
    });

}

void LedManager::loop() {

    xSemaphoreTake(_mutex, portMAX_DELAY);

    if(_currentPattern != nullptr) {
        _currentPattern->loop();
    }
    
    xSemaphoreGive(_mutex);

}

bool LedManager::updatePattern(JsonObject json) {

    xSemaphoreTake(_mutex, portMAX_DELAY);

    bool result = false;
    if(_directAccess == false) {

        if(json.containsKey("name")) {
            result = _changePattern(json);
        }else{
            result = _updatePattern(json);
        }

    }
    
    xSemaphoreGive(_mutex);
    return result;

}

void LedManager::setBrightness(uint8_t value) {

    xSemaphoreTake(_mutex, portMAX_DELAY);

    leds.setBrightness(value);
    
    xSemaphoreGive(_mutex);

}

bool LedManager::enableDLA() {

    xSemaphoreTake(_mutex, portMAX_DELAY);

    bool result = _enableDLA();
    
    xSemaphoreGive(_mutex);
    return result;

}

bool LedManager::_changePattern(JsonObject json) {

    std::string name = json["name"];

    ColorPattern* newPattern = _createPattern(name);
    if(newPattern == nullptr) return false;

    newPattern->setup();

    bool result = newPattern->update(json);
    if(result == false) {
        newPattern->dispose();
        delete newPattern;
        return false;
    }

    if(_currentPattern != nullptr) {
        _currentPattern->dispose();
        delete _currentPattern;
    }

    _currentPattern = newPattern;
    return true;
    
}

bool LedManager::_updatePattern(JsonObject json) {
    
    if(_currentPattern == nullptr) return false;

    return _currentPattern->update(json);

}

bool LedManager::_enableDLA() {

    if(_directAccess) return false;

    if(_currentPattern != nullptr) {
        _currentPattern->dispose();
        delete _currentPattern;
        _currentPattern = nullptr;
    }

    leds.clear();

    _udp.listen(7000);
    _directAccess = true;
    return true;

}

void LedManager::_onUdpPacket(AsyncUDPPacket& packet) {

    uint8_t* data = packet.data();
    int length = packet.length();

    xSemaphoreTake(_mutex, portMAX_DELAY);
    
    if(_directAccess) {

        uint8_t cmd = data[0];

        switch (cmd) {

            case 10:
                if(length == DLA_PAYLOAD_SIZE + 1) {
                    memcpy(leds.colors(), data + 1, DLA_PAYLOAD_SIZE);
                    leds.show();
                }
                break;

            case 20:
                leds.clear();
                break;
        }

    }

    xSemaphoreGive(_mutex);

}

ColorPattern* LedManager::_createPattern(std::string& name) {

    if(name == "solid") {
        return new SolidColorPattern();
    }else if(name == "fade") {
        return new FadePattern();
    }

    return nullptr;
}
