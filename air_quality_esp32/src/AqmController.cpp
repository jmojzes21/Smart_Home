
#include "AqmController.h"

#include <ArduinoJson.h>
#include <HTTPClient.h>

#include "helpers/DateFormats.h"

#define AQM_CONNECT_TIMEOUT_MS 10000
#define AQM_TCP_TIMEOUT_MS 5000

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

  auto& aqmHost = config.aqmBackendAddress;
  auto& apiKey = config.aqmApiKey;
  std::string url = aqmHost + "/api/air-quality";
  
  log_i("POST %s", url.c_str());
  log_i("Body %s", body.c_str());

  url += "?apiKey=" + apiKey;

  HTTPClient client;
  client.setConnectTimeout(AQM_CONNECT_TIMEOUT_MS);
  client.setTimeout(AQM_TCP_TIMEOUT_MS);
  client.begin(url.c_str());

  int statusCode = client.POST((uint8_t*)body.c_str(), body.length());
  log_i("Status: %d", statusCode);

  if(statusCode != 204) {
    String response = client.getString();
    log_e("%s", response.c_str());
  }

  client.end();

}
