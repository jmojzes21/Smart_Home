
#pragma once

#include <Arduino.h>
#include <string>

class LogClass {

    private:

    SemaphoreHandle_t _mutex;
    bool _ready = false;

    char* _buffer = nullptr;
    size_t _bufferCapacity = 0;
    size_t _bufferLength = 0;

    public:

    void setup(size_t bufferCapacity);
    void info(const char* format, ...);

    std::string getLogs();
    void clear();

    private:

    void _clear();

};

extern LogClass Log;
