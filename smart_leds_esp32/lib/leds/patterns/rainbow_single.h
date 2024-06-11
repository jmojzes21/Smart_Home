
#pragma once

#include "color_pattern.h"

class RainbowSinglePattern : public ColorPattern {

public:

    RainbowSinglePattern() {}

    void loop() override {}

    bool update(JsonObject p) override {}

    void dispose() override {}

};
