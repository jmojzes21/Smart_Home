
#include "helpers/Base64.h"
#include <mbedtls/base64.h>

namespace Base64 {

  std::string encode(uint8_t* inputBuffer, size_t inputSize, bool base64url) {

    std::vector<uint8_t> buffer;
    buffer.resize(2 * inputSize);

    size_t bytesWritten = 0;
    int result = mbedtls_base64_encode(buffer.data(), buffer.size(), &bytesWritten, inputBuffer, inputSize);
    
    if(result != 0) {

      if(result == MBEDTLS_ERR_BASE64_BUFFER_TOO_SMALL) {
        buffer.resize(bytesWritten);
        result = mbedtls_base64_encode(buffer.data(), buffer.size(), &bytesWritten, inputBuffer, inputSize);
      }else{
        return "";
      }

      if(result != 0) return "";
    }
    
    std::string encoded = std::string((char*)buffer.data(), bytesWritten);

    if(base64url) {
      for(size_t i = 0; i < encoded.length(); i++) {
        char c = encoded[i];
        if(c == '+') {
          encoded[i] = '-';
        }else if(c == '/') {
          encoded[i] = '_';
        }
      }

      size_t i = encoded.find('=');
      if(i != -1) {
        encoded = encoded.substr(0, i);
      }
    }

    return encoded;
  }

  std::string encodeString(const std::string& input, bool base64url) {
    return encode((uint8_t*)input.data(), input.size(), base64url);
  }

  bool decode(std::string input, std::vector<uint8_t>& output, bool base64url) {
    
    if(base64url) {
      for(size_t i = 0; i < input.length(); i++) {
        char c = input[i];
        if(c == '-') {
          input[i] = '+';
        }else if(c == '_') {
          input[i] = '/';
        }
      }

      while(input.length() % 4 != 0) {
        input += "=";
      }
    }

    output.resize(input.size());

    size_t bytesWritten = 0;
    int result = mbedtls_base64_decode(output.data(), output.size(), &bytesWritten, (uint8_t*)input.data(), input.size());

    if(result != 0) {

      if(result == MBEDTLS_ERR_BASE64_BUFFER_TOO_SMALL) {
        output.resize(bytesWritten);
        result = mbedtls_base64_decode(output.data(), output.size(), &bytesWritten, (uint8_t*)input.data(), input.size());
      }else{
        return false;
      }

      if(result != 0) return false;
    }

    output.resize(bytesWritten);
    return true;
  }

  bool decodeString(const std::string& input, std::string& output, bool base64url) {
    std::vector<uint8_t> buffer;
    bool result = decode(input, buffer, base64url);
    if(!result) return false;

    output = std::string((char*)buffer.data(), buffer.size());
    return true;
  }

}

