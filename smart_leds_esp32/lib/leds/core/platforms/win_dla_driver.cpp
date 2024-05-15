
#include "platform_driver.h"

#ifdef _WIN32

#include <WinSock2.h>
#include <WS2tcpip.h>

#include <stdio.h>

#pragma comment(lib, "Ws2_32.lib")

namespace platform_led_driver {

    static WSADATA wsaData;
    static SOCKET client = INVALID_SOCKET;
    static Color* colors = nullptr;
    static int ledCount = 0;

    static char buffer[100];

    void sendData(char* buffer, int size);

    void init(Color* colors, int ledCount, const char* ipAddress, int port) {

        platform_led_driver::colors = colors;
        platform_led_driver::ledCount = ledCount;

        int result = WSAStartup(MAKEWORD(2, 2), &wsaData);

        if (result != 0) {
            printf("WSAStartup failed: %d\n", result);
            exit(1);
        }

        client = socket(AF_INET, SOCK_DGRAM, IPPROTO_UDP);

        if (client == INVALID_SOCKET) {
            printf("Error at socket(): %d\n", (int)WSAGetLastError());
            WSACleanup();
            exit(1);
        }

        sockaddr_in addr;
        addr.sin_family = AF_INET;
        addr.sin_port = htons(port);

        result = inet_pton(AF_INET, ipAddress, &addr.sin_addr.s_addr);

        if (result != 1) {
            printf("Invalid ip address: %d\n", (int)WSAGetLastError());
            WSACleanup();
            exit(1);
        }

        result = connect(client, (sockaddr*)&addr, sizeof(addr));

        if (result == SOCKET_ERROR) {
            printf("Error at connect(): %d\n", (int)WSAGetLastError());
            closesocket(client);
            WSACleanup();
            exit(1);
        }

        memset(colors, 0, 3 * ledCount);
        show();

    }

    void show() {

        buffer[0] = 10;
        memcpy_s(buffer + 1, sizeof(buffer) - 1, colors, 3 * ledCount);

        int size = 3 * ledCount + 1;

        sendData(buffer, size);

    }

    void setBrightness(uint8_t value) {

        buffer[0] = 21;
        buffer[1] = value;

        sendData(buffer, 2);

    }

    void clear() {

        buffer[0] = 20;

        sendData(buffer, 1);

    }

    void dispose() {
        closesocket(client);
        WSACleanup();
    }

    void sendData(char* buffer, int size) {

        int result = send(client, buffer, size, 0);

        if (result == SOCKET_ERROR) {
            printf("Error at send(): %d\n", (int)WSAGetLastError());
            closesocket(client);
            WSACleanup();
            exit(1);
        }

    }

}

#endif
