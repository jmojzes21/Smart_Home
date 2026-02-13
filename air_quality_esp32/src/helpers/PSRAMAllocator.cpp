
#include "helpers/PSRAMAllocator.h"

void* SpiRamAllocator::allocate(size_t size) {
  return heap_caps_malloc(size, MALLOC_CAP_SPIRAM);
}

void SpiRamAllocator::deallocate(void* pointer) {
  heap_caps_free(pointer);
}

void* SpiRamAllocator::reallocate(void* ptr, size_t new_size) {
  return heap_caps_realloc(ptr, new_size, MALLOC_CAP_SPIRAM);
}
