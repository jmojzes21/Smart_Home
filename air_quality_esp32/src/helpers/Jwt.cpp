
#include "helpers/Jwt.h"

#include <Arduino.h>
#include <vector>
#include <mbedtls/md.h>

#include "helpers/Base64.h"

bool JwtToken::decode(const std::string& secretKey, const std::string& token) {

  payload.clear();

  std::string header64;
  std::string payload64;
  std::string signature64;
  if(!_extractTokenData(token, header64, payload64, signature64)) {
    log_i("Bad jwt token %s", token.c_str());
    return false;
  }

  std::string headerJson;
  std::string payloadJson;

  if(!Base64::decodeString(header64, headerJson, true)) {
    log_i("Bad header %s", header64.c_str());
    return false;
  }

  if(!Base64::decodeString(payload64, payloadJson, true)) {
    log_i("Bad payload %s", payload64.c_str());
    return false;
  }

  if(!_checkHeader(headerJson)) {
    return false;
  }

  if(!_checkSignature(secretKey, header64, payload64, signature64)) {
    return false;
  }

  auto error = deserializeJson(payload, payloadJson);
  if(error) {
    log_i("Bad payload json %s", payloadJson.c_str());
    return false;
  }

  return true;

}

bool JwtToken::isValid(uint32_t time) {

  uint32_t iat = payload["iat"];
  uint32_t exp = payload["exp"];

  return time >= iat && time < exp;
}

bool JwtToken::_extractTokenData(const std::string& token, std::string& header64, 
  std::string& payload64, std::string& signature64) {

  size_t p1 = token.find('.', 0);
  if(p1 == -1) {
    return false;
  }

  header64 = token.substr(0, p1);
  
  size_t p2 = token.find('.', p1 + 1);
  if(p2 == -1) {
    return false;
  }

  payload64 = token.substr(p1 + 1, p2 - p1 - 1);
  signature64 = token.substr(p2 + 1);

  if(header64.size() == 0 || payload64.size() == 0 || signature64.size() == 0) {
    return false;
  }

  return true;
}

bool JwtToken::_checkHeader(std::string& headerJson) {

  JsonDocument doc;

  auto error = deserializeJson(doc, headerJson);
  if(error) {
    log_i("Bad header json %s", headerJson.c_str());
    return false;
  }

  std::string algorithm = doc["alg"];
  std::string type = doc["typ"];

  if(algorithm != "HS256") {
    log_i("Unsupported algorithm %s", algorithm.c_str());
    return false;
  }

  if(type != "JWT") {
    log_i("Unsupported type %s", type.c_str());
    return false;
  }

  return true;
}

bool JwtToken::_checkSignature(const std::string& secretKey, std::string& header64,
  std::string& payload64, std::string& expectedSignature64) {
  
  std::string data = header64 + "." + payload64;
  uint8_t signature[32];

  mbedtls_md_context_t mdContext;
  mbedtls_md_type_t mdType = MBEDTLS_MD_SHA256;

  mbedtls_md_init(&mdContext);
  mbedtls_md_setup(&mdContext, mbedtls_md_info_from_type(mdType), 1);

  mbedtls_md_hmac_starts(&mdContext, (uint8_t*)secretKey.data(), secretKey.size());
  mbedtls_md_hmac_update(&mdContext, (uint8_t*)data.data(), data.size());
  mbedtls_md_hmac_finish(&mdContext, signature);

  mbedtls_md_free(&mdContext);

  std::string signature64 = Base64::encode(signature, sizeof(signature), true);
  
  if(signature64 != expectedSignature64) {
    log_i("Bad signature, expected: %s, actual: %s", expectedSignature64.c_str(), signature64.c_str());
    return false;
  }

  return true;
}
