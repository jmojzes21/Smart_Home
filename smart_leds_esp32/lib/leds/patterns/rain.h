
#pragma once

#include "color_pattern.h"

class RainPattern : public ColorPattern {

public:

    RainPattern() {}

    void loop() override {}

    bool update(JsonObject p) override {}

    void dispose() override {}

};
