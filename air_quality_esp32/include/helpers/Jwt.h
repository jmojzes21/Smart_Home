
#pragma once

#include <string>
#include <ArduinoJson.h>

class JwtToken {

  public:

  JsonDocument payload;

  bool decode(const std::string& secretKey, const std::string& token);
  bool isValid(uint32_t time);

  private:

  bool _extractTokenData(const std::string& token, std::string& header64, 
    std::string& payload64, std::string& signature64);

  bool _checkHeader(std::string& headerJson);

  bool _checkSignature(const std::string& secretKey, std::string& header64,
    std::string& payload64, std::string& expectedSignature64);

};

