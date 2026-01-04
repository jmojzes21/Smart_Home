
#pragma once

#include <Arduino.h>
#include <ArduinoJson.h>

struct SpiRamAllocator : ArduinoJson::Allocator {
  void* allocate(size_t size) override;
  void deallocate(void* pointer) override;
  void* reallocate(void* ptr, size_t new_size) override;
};
