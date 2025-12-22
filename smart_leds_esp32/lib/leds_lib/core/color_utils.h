
#pragma once

#include <cmath>
#include <vector>

#include "color.h"

#ifdef _WIN32
#define M_PI 3.14159265359
#endif

namespace utils {

    Color getRandomColor(std::vector<Color> colors);
    void getBasicColors(std::vector<Color>& colors);

    Color scaleColor(Color color, float scale);
    Color lerpColor(Color a, Color b, float p);

    Color getRainbowColor(uint8_t hue);

    int getRandomNumber(int max);

}