
#include "AqmController.h"

#include <ArduinoJson.h>
#include <HTTPClient.h>
#include <LittleFS.h>

#include "helpers/DateFormats.h"

#define AQM_CONNECT_TIMEOUT_MS 5000
#define AQM_TCP_TIMEOUT_MS 5000

#define MEASUREMENTS_BUFFER_FILE_PATH "/buffer.txt"

AqmController::AqmController(DeviceController* deviceController, SensorController* sensorController) {
  this->deviceController = deviceController;
  this->sensorController = sensorController;
}

void AqmController::init() {
  
  sensorController->setOnSaveDataAqm([&](struct tm time, AirQualityHistory& aqData) {
    sendMeasurement(time, aqData);
  });

}

void AqmController::sendMeasurement(tm time, AirQualityHistory &aqData) {

  auto& config = deviceController->getConfig();

  std::string timeText = DateFormats::formatDateTime(time);
  
  JsonDocument doc;

  doc["station_id"] = config.aqmDeviceUuid;
  doc["time"] = timeText;

  doc["temp_c"] = aqData.temperatureMetrics.getAverage();
  doc["press_hpa"] = aqData.pressureMetrics.getAverage();
  doc["hum_p"] = aqData.humidityMetrics.getAverage();
  doc["pm2p5_ugm3"] = aqData.pm25Metrics.getAverage();

  std::string body = "";
  serializeJson(doc, body);
  sendMeasurement(body);

}

void AqmController::sendMeasurement(std::string& data) {

  bool isBufferEmpty = sendBufferedMeasurements();

  if(!isBufferEmpty) {
    saveMeasurementToBuffer(data);
    return;
  }

  auto& config = deviceController->getConfig();
  auto& aqmHost = config.aqmBackendAddress;
  auto& apiKey = config.aqmApiKey;

  std::string url = aqmHost + "/api/air-quality";
  
  log_i("POST %s", url.c_str());
  log_i("Body %s", data.c_str());

  url += "?apiKey=" + apiKey;

  // send request

  HTTPClient client;
  client.setConnectTimeout(AQM_CONNECT_TIMEOUT_MS);
  client.setTimeout(AQM_TCP_TIMEOUT_MS);

  if(!client.begin(url.c_str())) {
    saveMeasurementToBuffer(data);
    return;
  }

  int statusCode = client.POST((uint8_t*)data.c_str(), data.length());
  log_i("Status: %d", statusCode);

  if(statusCode != 204) {
    String response = statusCode > 0 ? client.getString() : client.errorToString(statusCode);
    log_e("%s", response.c_str());

    saveMeasurementToBuffer(data);
  }

  client.end();

}

bool AqmController::sendBufferedMeasurements() {

  if(!LittleFS.exists(MEASUREMENTS_BUFFER_FILE_PATH)) {
    return true;
  }

  log_i("Send buffered measurements");

  File file = LittleFS.open(MEASUREMENTS_BUFFER_FILE_PATH, FILE_READ);
  if(!file) {
    log_e("Can't open file %s", MEASUREMENTS_BUFFER_FILE_PATH);
    return false;
  }

  std::string data;
  data.reserve(file.size() + 4);

  data += "[";
  file.readBytes(&data[0], data.length());
  file.close();
  data += "]";

  // send request

  auto& config = deviceController->getConfig();
  auto& aqmHost = config.aqmBackendAddress;
  auto& apiKey = config.aqmApiKey;

  std::string url = aqmHost + "/api/air-quality/bulk";
  log_i("POST %s", url.c_str());
  url += "?apiKey=" + apiKey;

  HTTPClient client;
  client.setConnectTimeout(AQM_CONNECT_TIMEOUT_MS);
  client.setTimeout(AQM_TCP_TIMEOUT_MS);

  if(!client.begin(url.c_str())) {
    return false;
  }

  int statusCode = client.POST((uint8_t*)data.c_str(), data.length());
  log_i("Status: %d", statusCode);

  if(statusCode != 204) {
    String response = statusCode > 0 ? client.getString() : client.errorToString(statusCode);
    log_e("%s", response.c_str());

    client.end();
    return false;
  }

  client.end();

  LittleFS.remove(MEASUREMENTS_BUFFER_FILE_PATH);
  return true;
}

void AqmController::saveMeasurementToBuffer(std::string& data) {
  
  log_i("Save measurement to buffer %s", data.c_str());

  bool append = LittleFS.exists(MEASUREMENTS_BUFFER_FILE_PATH);

  File file = LittleFS.open(MEASUREMENTS_BUFFER_FILE_PATH, append ? FILE_APPEND : FILE_WRITE);
  if(!file) {
    log_e("Can't open file %s", MEASUREMENTS_BUFFER_FILE_PATH);
    return;
  }

  if(append) {
    file.print(',');
  }
  
  file.print(data.c_str());
  file.close();

}
