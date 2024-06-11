
#pragma once

#include "color_pattern.h"

class RainbowPattern : public ColorPattern {

public:

    RainbowPattern() {}

    void loop() override {}

    bool update(JsonObject p) override {}

    void dispose() override {}

};
