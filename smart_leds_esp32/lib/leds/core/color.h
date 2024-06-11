
#pragma once

#include <inttypes.h>

struct Color {

    uint8_t r;
    uint8_t g;
    uint8_t b;

    Color();
    Color(uint8_t r, uint8_t g, uint8_t b);
    Color(uint32_t code);

    bool operator==(const Color& other) const;

};
