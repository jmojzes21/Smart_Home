
#include "log.h"

void LogClass::setup(size_t bufferCapacity) {
    
    if(bufferCapacity < 256) {
        bufferCapacity = 256;
    }

    _mutex = xSemaphoreCreateMutex();

    _bufferCapacity = bufferCapacity;
    _bufferLength = 0;

    _buffer = new char[_bufferCapacity];
    memset(_buffer, 0, _bufferCapacity);

    _ready = true;

}

void LogClass::info(const char* format, ...) {

    if(_ready == false) return;

    if(xSemaphoreTake(_mutex, portMAX_DELAY) == pdTRUE) {
        
        va_list args;
        va_start(args, format);

        char* start = _buffer + _bufferLength;
        int remain = _bufferCapacity - _bufferLength;

        if(remain < 48) {
            _clear();
            start = _buffer;
            remain = _bufferCapacity;
        }

        int n = vsnprintf(start, remain, format, args);
        _bufferLength += n;

        if(n + 1 > remain) {
            _clear();
            start = _buffer;
            remain = _bufferCapacity;
            vsnprintf(start, remain, format, args);
            _bufferLength = n;
        }

        va_end(args);
        xSemaphoreGive(_mutex);
    }

}

std::string LogClass::getLogs() {

    std::string logs = "";
    if(_ready == false) return logs;

    if(xSemaphoreTake(_mutex, portMAX_DELAY) == pdTRUE) {
        logs = std::string(_buffer, _bufferLength);
        xSemaphoreGive(_mutex);
    }

    return logs;
}

void LogClass::clear() {

    if(_ready == false) return;

    if(xSemaphoreTake(_mutex, portMAX_DELAY) == pdTRUE) {
        _clear();
        xSemaphoreGive(_mutex);
    }
}

void LogClass::_clear() {
    _buffer[0] = 0;
    _bufferLength = 0;
}

LogClass Log;
