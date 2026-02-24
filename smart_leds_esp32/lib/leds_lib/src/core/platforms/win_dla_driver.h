#pragma once

#ifdef _WIN32

#include <inttypes.h>

#include <WinSock2.h>
#include <WS2tcpip.h>
#include <stdio.h>

#pragma comment(lib, "Ws2_32.lib")

#include "core/led_driver.h"
#include "core/color.h"

class WinDlaDriver : public ILedDriver {

private:

    const char* _ipAddress = nullptr;
    int _port = 0;

    WSADATA _wsaData = { 0 };
    SOCKET _client = INVALID_SOCKET;
    uint64_t _lastShow = 0;

    char _buffer[100] = { 0 };

public:

    WinDlaDriver(const char* ipAddress, int port);

    void init() override;
    void show() override;
    void setBrightness(uint8_t value) override;
    void dispose() override;

private:

    void _sendData(char* buffer, int size);

};

#endif
