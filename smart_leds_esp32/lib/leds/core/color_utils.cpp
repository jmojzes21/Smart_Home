
#include "color_utils.h"

namespace utils {

    Color getRandomColor(std::vector<Color> colors) {
        int i = getRandomNumber(colors.size());
        return colors[i];
    }

    void getBasicColors(std::vector<Color>& colors) {
        colors.emplace_back(244, 67, 54);
        colors.emplace_back(233, 30, 99);
        colors.emplace_back(156, 39, 176);
        colors.emplace_back(103, 58, 183);
        colors.emplace_back(63, 81, 181);
        colors.emplace_back(33, 150, 243);
        colors.emplace_back(3, 169, 244);
        colors.emplace_back(0, 188, 212);
        colors.emplace_back(0, 150, 136);
        colors.emplace_back(76, 175, 80);
        colors.emplace_back(139, 195, 74);
        colors.emplace_back(205, 220, 57);
        colors.emplace_back(255, 235, 59);
        colors.emplace_back(255, 193, 7);
        colors.emplace_back(255, 152, 0);
        colors.emplace_back(255, 87, 34);
        colors.emplace_back(121, 85, 72);
        colors.emplace_back(96, 125, 139);
    }

    int getRandomNumber(int max) {
        return rand() % max;
    }

}