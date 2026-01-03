
#pragma once

#include "time.h"
#include <string>

namespace DateFormats {

  void formatDateTime(tm t, char* buffer, size_t bufferSize);
  std::string formatDateTime(tm t);

}
