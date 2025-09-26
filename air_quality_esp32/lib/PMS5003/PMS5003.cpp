
#include "PMS5003.h"

#define PMS_HEADER 0x424D
#define PMS_FRAME_LENGTH 28
#define PMS_READ_TIMEOUT 4000

PMS5003_Sensor::PMS5003_Sensor() {}

void PMS5003_Sensor::init(HardwareSerial* serial, int8_t rxPin, int8_t txPin) {

  _serial = serial;
  _rxPin = rxPin;
  _txPin = txPin;

  _serial->begin(9600, SERIAL_8N1, _rxPin, _txPin);
  
  _serial->write(_passiveMode, sizeof(_passiveMode));
  _serial->flush();

  _clearRxBuffer();
  
}

bool PMS5003_Sensor::read(PMS5003_Data* data) {

  _clearRxBuffer();

  _serial->write(_passiveRead, sizeof(_passiveRead));
  _serial->flush();

  uint32_t startTime = millis();

  while(_serial->available() < 32) {

    if(millis() - startTime > PMS_READ_TIMEOUT) {
      log_e("PMS5003 read timeout\n");
      return false;
    }

    delay(100);
  }

  uint8_t* buffer = (uint8_t*)data;
  _serial->readBytes(buffer, 32);

  for(int i = 0; i < 32; i += 2) {
    uint8_t t = buffer[i];
    buffer[i] = buffer[i + 1];
    buffer[i + 1] = t;
  }

  if(data->_header != PMS_HEADER) {
    log_e("Header, expected: 0x%04X, actual: 0x%004X\n", PMS_HEADER, data->_header);
    return false;
  }

  if(data->_frameLength != PMS_FRAME_LENGTH) {
    log_e("Frame length, expected: %d, actual: %d\n", PMS_FRAME_LENGTH, data->_frameLength);
    return false;
  }

  uint16_t sum = 0;

  for(int i = 0; i < 30; i++) {
    sum += buffer[i];
  }

  if(sum != data->_checkSum) {
    log_e("Check sum, expected: %d, actual: %d\n", data->_checkSum, sum);
    return false;
  }

  return true;
}

void PMS5003_Sensor::_clearRxBuffer() {
  size_t length = _serial->available();
  
  if(length != 0) {

    char buffer[32];
    while(length != 0) {
      size_t toRead = min(length, sizeof(buffer));
      size_t bytesRead = _serial->readBytes(buffer, toRead);
      length -= bytesRead;
    }

  }
}
