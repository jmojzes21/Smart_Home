
#include "device.h"

void Device::restart(int ms) {

    if(_restartTicker.active()) return;

    _restartTicker.once_ms(ms, []() {
        ESP.restart();
    });

}
