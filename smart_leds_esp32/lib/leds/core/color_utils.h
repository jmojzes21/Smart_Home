
#pragma once

#include <cmath>
#include <vector>

#include "color.h"

#define M_PI 3.14159265359

namespace utils {

    Color getRandomColor(std::vector<Color> colors);
    void getBasicColors(std::vector<Color>& colors);

    int getRandomNumber(int max);

}