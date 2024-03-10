
#pragma once

#include <string>

class Device {
    public:
    std::string name = "";
    std::string password = "";

    const char* version = nullptr;
    const char* deviceType = nullptr;

};
