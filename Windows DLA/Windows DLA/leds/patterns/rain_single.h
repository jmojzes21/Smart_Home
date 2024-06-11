
#pragma once

#include "color_pattern.h"

class RainSinglePattern : public ColorPattern {

public:

    RainSinglePattern() {}

    void loop() override {}

    bool update(JsonObject p) override {}

    void dispose() override {}

};
