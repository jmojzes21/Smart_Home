
#pragma once

#include <inttypes.h>
#include <string>
#include <vector>

namespace Base64 {

  std::string encode(uint8_t* inputBuffer, size_t inputSize, bool base64url = false);
  std::string encodeString(const std::string& input, bool base64url = false);

  bool decode(std::string input, std::vector<uint8_t>& output, bool base64url = false);
  bool decodeString(const std::string& input, std::string& output, bool base64url = false);

}
