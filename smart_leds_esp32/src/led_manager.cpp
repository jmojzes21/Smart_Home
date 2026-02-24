
#include "led_manager.h"

#include "patterns/color_pattern.h"
#include "patterns/single_color.h"
#include "patterns/wave.h"
#include "patterns/rainbow.h"
#include "patterns/rainbow_balls.h"
#include "patterns/rain.h"

#include "core/platforms/esp32_driver.h"

#define DLA_PAYLOAD_SIZE (sizeof(Color) * LED_COUNT)

void LedManager::setup() {

    Serial.printf("Postavi LED upravitelja\n");

    _ledDriver = new Esp32Driver();

    _mutex = xSemaphoreCreateMutex();

    _ledDriver->init();

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

    if(_directAccess) {
        _disableDLA();
    }

    std::string name = json["name"];

    if(name == _currentPatternName) {
        result = _updatePattern(json);
    }else{
        result = _changePattern(name, json);
    }

    xSemaphoreGive(_mutex);
    return result;

}

void LedManager::clearPattern() {

    xSemaphoreTake(_mutex, portMAX_DELAY);

    if(_directAccess) {
        _disableDLA();
    }

    _clearPattern();

    xSemaphoreGive(_mutex);
    
}

void LedManager::setBrightness(uint8_t value) {

    xSemaphoreTake(_mutex, portMAX_DELAY);

    _ledDriver->setBrightness(value);
    
    xSemaphoreGive(_mutex);

}

void LedManager::enableDLA() {

    xSemaphoreTake(_mutex, portMAX_DELAY);

    _enableDLA();

    xSemaphoreGive(_mutex);

}

bool LedManager::_changePattern(std::string& name, JsonObject json) {

    ColorPattern* newPattern = _createPattern(name);
    if(newPattern == nullptr) return false;

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
    _currentPatternName = name;
    return true;
    
}

bool LedManager::_updatePattern(JsonObject json) {
    
    if(_currentPattern == nullptr) return false;

    return _currentPattern->update(json);

}

void LedManager::_clearPattern() {

    if(_currentPattern != nullptr) {

        _currentPattern->dispose();
        delete _currentPattern;

        _currentPatternName = "";
        _currentPattern = nullptr;
    }

    _ledDriver->clear();
    _ledDriver->show();

}

void LedManager::_enableDLA() {

    if(_directAccess) return;

    _clearPattern();

    _udp.listen(7000);
    _directAccess = true;

}

void LedManager::_disableDLA() {

    if(_directAccess) {
        _udp.close();
        _directAccess = false;
    }

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
                    memcpy(_ledDriver->colors(), data + 1, DLA_PAYLOAD_SIZE);
                    _ledDriver->show();
                }
                break;

            case 20:
                _ledDriver->clear();
                break;
            case 21:
                if(length == 2) {
                    uint8_t brightness = data[1];
                    _ledDriver->setBrightness(brightness);
                }
                break;
        }

    }

    xSemaphoreGive(_mutex);

}

ColorPattern* LedManager::_createPattern(std::string& name) {

    if(name == "single") {
        return new SingleColorPattern(_ledDriver);
    }else if(name == "wave") {
        return new WavePattern(_ledDriver);
    }else if(name == "rainbow") {
        return new RainbowPattern(_ledDriver);
    }else if(name == "rainbow_balls") {
        return new RainbowBallsPattern(_ledDriver);
    }else if(name == "rain") {
        return new RainPattern(_ledDriver);
    }

    return nullptr;
}
