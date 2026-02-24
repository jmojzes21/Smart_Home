
#ifdef _WIN32

#include "win_dla_driver.h"
#include "core/arduino_time.h"

#define SHOW_PERIOD_MICROS 2000 

WinDlaDriver::WinDlaDriver(const char* ipAddress, int port) {
    _ipAddress = ipAddress;
    _port = port;
}

void WinDlaDriver::init() {

    int result = WSAStartup(MAKEWORD(2, 2), &_wsaData);

    if (result != 0) {
        printf("WSAStartup failed: %d\n", result);
        exit(1);
    }

    _client = socket(AF_INET, SOCK_DGRAM, IPPROTO_UDP);

    if (_client == INVALID_SOCKET) {
        printf("Error at socket(): %d\n", (int)WSAGetLastError());
        WSACleanup();
        exit(1);
    }

    sockaddr_in addr;
    addr.sin_family = AF_INET;
    addr.sin_port = htons(_port);

    result = inet_pton(AF_INET, _ipAddress, &addr.sin_addr.s_addr);

    if (result != 1) {
        printf("Invalid ip address: %d\n", (int)WSAGetLastError());
        WSACleanup();
        exit(1);
    }

    result = connect(_client, (sockaddr*)&addr, sizeof(addr));

    if (result == SOCKET_ERROR) {
        printf("Error at connect(): %d\n", (int)WSAGetLastError());
        closesocket(_client);
        WSACleanup();
        exit(1);
    }

    memset(colors(), 0, 3 * ledCount());
}

void WinDlaDriver::show() {

    uint64_t now = micros();

    if (now - _lastShow >= SHOW_PERIOD_MICROS) {

        _lastShow = now;

        _buffer[0] = 10;
        memcpy_s(_buffer + 1, sizeof(_buffer) - 1, colors(), 3 * ledCount());

        int size = 3 * ledCount() + 1;

        _sendData(_buffer, size);

    }
}

void WinDlaDriver::setBrightness(uint8_t value) {

    _buffer[0] = 21;
    _buffer[1] = value;

    _sendData(_buffer, 2);
}

void WinDlaDriver::dispose() {
    closesocket(_client);
    WSACleanup();
}

void WinDlaDriver::_sendData(char* buffer, int size) {

    int result = send(_client, buffer, size, 0);

    if (result == SOCKET_ERROR) {
        printf("Error at send(): %d\n", (int)WSAGetLastError());
        closesocket(_client);
        WSACleanup();
        exit(1);
    }

}

#endif
