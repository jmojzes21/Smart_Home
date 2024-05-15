
#include "color.h"

Color::Color() {
    r = 0;
    g = 0;
    b = 0;
}

Color::Color(uint8_t r, uint8_t g, uint8_t b) {
    this->r = r;
    this->g = g;
    this->b = b;
}

Color::Color(uint32_t code) {
    r = (code >> 16) & 0xFF;
    g = (code >> 8) & 0xFF;
    b = code & 0xFF;
}
