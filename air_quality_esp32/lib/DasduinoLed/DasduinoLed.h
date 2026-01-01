
#include <inttypes.h>
#include "LedColors.h"

namespace DasduinoLed {

  void init();
  void setBrightness(uint8_t b);

  void showColor(uint32_t color);
  void clear();

}
