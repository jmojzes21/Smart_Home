
#pragma once

#ifdef ARDUINO

#include <Arduino.h>

#elif _WIN32

#include <inttypes.h>

namespace ArduinoTime {
	void init();
}

uint64_t micros();


#endif
