
#include "AqmController.h"

#include <ArduinoJson.h>
#include <HTTPClient.h>
#include <LittleFS.h>

#include "helpers/DateTime.h"

#define AQM_CONNECT_TIMEOUT_MS 5000
#define AQM_TCP_TIMEOUT_MS 20000

#define MEASUREMENTS_BUFFER_FILE_PATH "/buffer.txt"

static std::string getErrorMessage(int code, HTTPClient& client); 

AqmController::AqmController(DeviceController* deviceController, SensorController* sensorController, DeviceLogger* logs) {
  this->deviceController = deviceController;
  this->sensorController = sensorController;
  this->logs = logs;
}

void AqmController::init() {

  sensorController->setOnSaveDataAqm([&](DateTime time, AirQualityHistory& aqData) {
    auto& config = deviceController->getAqmConfig();
    bool shouldSend = config.sendData;

    saveMeasurement(time, aqData, shouldSend);

    if(shouldSend) {
      sendLogs();
    }
  });

}

void AqmController::saveMeasurement(DateTime time, AirQualityHistory &aqData, bool shouldSend) {

  JsonDocument doc;

  doc["time"] = time.toString();
  doc["temp_c"] = aqData.temperatureMetrics.getAverage();
  doc["press_hpa"] = aqData.pressureMetrics.getAverage();
  doc["hum_p"] = aqData.humidityMetrics.getAverage();
  doc["pm2p5_ugm3"] = aqData.pm25Metrics.getAverage();

  std::string body = "";
  serializeJson(doc, body);

  if(!shouldSend) {
    saveMeasurementToBuffer(body);
    return;
  }

  sendMeasurement(body);

}

void AqmController::sendMeasurement(std::string& data) {

  bool isBufferEmpty = sendBufferedMeasurements();

  if(!isBufferEmpty) {
    saveMeasurementToBuffer(data);
    return;
  }

  auto& config = deviceController->getAqmConfig();
  auto& deviceUuid = config.deviceUuid;
  auto& host = config.backendAddress;
  auto& apiKey = config.apiKey;

  std::string url = host + "/api/air-quality/" + deviceUuid;
  std::string url2 = url + "?apiKey=" + apiKey;
  
  log_i("POST %s", url.c_str());
  log_i("Body %s", data.c_str());

  // send request

  HTTPClient client;
  client.setConnectTimeout(AQM_CONNECT_TIMEOUT_MS);
  client.setTimeout(AQM_TCP_TIMEOUT_MS);

  if(!client.begin(url2.c_str())) {
    saveMeasurementToBuffer(data);
    return;
  }

  int statusCode = client.POST((uint8_t*)data.c_str(), data.length());
  log_i("Status: %d", statusCode);

  if(statusCode != 204) {
    std::string message = getErrorMessage(statusCode, client);
    log_e("%s", message.c_str());

    logs->logError("Nije moguće poslati izmjerene vrijednosti, POST %s, status: %d, greška: %s", url.c_str(), statusCode, message.c_str());
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

  size_t fileSize = file.size();

  std::vector<char> data;
  data.resize(fileSize + 4, 0);

  data[0] = '[';
  file.readBytes(&data[1], fileSize);
  file.close();
  data[fileSize + 1] = ']';

  // send request

  auto& config = deviceController->getAqmConfig();
  auto& deviceUuid = config.deviceUuid;
  auto& host = config.backendAddress;
  auto& apiKey = config.apiKey;

  std::string url = host + "/api/air-quality/" + deviceUuid + "/bulk";
  std::string url2 = url + "?apiKey=" + apiKey;

  log_i("POST %s", url.c_str());

  HTTPClient client;
  client.setConnectTimeout(AQM_CONNECT_TIMEOUT_MS);
  client.setTimeout(AQM_TCP_TIMEOUT_MS);

  if(!client.begin(url2.c_str())) {
    return false;
  }

  int statusCode = client.POST((uint8_t*)data.data(), fileSize + 2);
  log_i("Status: %d", statusCode);

  if(statusCode != 201) {
    std::string message = getErrorMessage(statusCode, client);
    log_e("%s", message.c_str());

    logs->logError("Nije moguće poslati mjerenja iz međuspremnika, POST %s, status: %d, greška: %s", url.c_str(), statusCode, message.c_str());

    client.end();
    return false;
  }

  String response = client.getString();
  client.end();

  JsonDocument doc;
  deserializeJson(doc, response);
  
  int count = doc["count"];
  logs->logInfo("Mjerenja iz međuspremnika su uspješno poslana, ukupno: %d", count);

  LittleFS.remove(MEASUREMENTS_BUFFER_FILE_PATH);
  return true;
}

void AqmController::saveMeasurementToBuffer(std::string& data) {
  
  log_i("Save measurement to buffer %s", data.c_str());
  logs->logInfo("Spremi izmjerene vrijednosti u međuspremnik");

  bool append = LittleFS.exists(MEASUREMENTS_BUFFER_FILE_PATH);

  File file = LittleFS.open(MEASUREMENTS_BUFFER_FILE_PATH, append ? FILE_APPEND : FILE_WRITE);
  if(!file) {
    log_e("Can't open file %s", MEASUREMENTS_BUFFER_FILE_PATH);
    return;
  }

  if(append) {
    file.print(',');
  }
  
  file.write((uint8_t*)data.c_str(), data.length());
  file.close();

}


void AqmController::sendLogs() {
  logs->takeLogFileMutex();
  sendLogsInternal();
  logs->giveLogFileMutex();
}

void AqmController::sendLogsInternal() {

  if(!LittleFS.exists(LOGS_FILE_PATH)) {
    return;
  }

  log_i("Send logs");

  File file = LittleFS.open(LOGS_FILE_PATH, FILE_READ);
  if(!file) {
    log_e("Can't open file %s", LOGS_FILE_PATH);
    return;
  }

  size_t fileSize = file.size();

  std::vector<char> data;
  data.resize(fileSize + 4, 0);

  data[0] = '[';
  file.readBytes(&data[1], fileSize);
  file.close();
  data[fileSize + 1] = ']';

  // send request

  auto& config = deviceController->getAqmConfig();
  auto& deviceUuid = config.deviceUuid;
  auto& host = config.backendAddress;
  auto& apiKey = config.apiKey;

  std::string url = host + "/api/station-logs/" + deviceUuid;
  std::string url2 = url + "?apiKey=" + apiKey;

  log_i("POST %s", url.c_str());

  HTTPClient client;
  client.setConnectTimeout(AQM_CONNECT_TIMEOUT_MS);
  client.setTimeout(AQM_TCP_TIMEOUT_MS);

  if(!client.begin(url2.c_str())) {
    return;
  }

  int statusCode = client.POST((uint8_t*)data.data(), fileSize + 2);
  log_i("Status: %d", statusCode);

  if(statusCode != 201) {
    std::string message = getErrorMessage(statusCode, client);
    log_e("%s", message.c_str());

    logs->logError("Nije moguće poslati logove, POST %s, status: %d, greška: %s", url.c_str(), statusCode, message.c_str());

    client.end();
    return;
  }

  client.end();
  LittleFS.remove(LOGS_FILE_PATH);
  
}

std::string getErrorMessage(int code, HTTPClient& client) {

  if(code > 0) {

    if(code == 204) {
      return "";
    }

    int bodySize = client.getSize();
    if(bodySize <= 0 || bodySize >= 4096) {
      return "";
    }
    
    String body = client.getString();
    return std::string(body.c_str(), body.length());
  }

  switch(code) {
  case HTTPC_ERROR_CONNECTION_REFUSED:
    return PROGMEM("povezivanje nije uspjelo");

  case HTTPC_ERROR_SEND_HEADER_FAILED:
    return PROGMEM("slanje zaglavlja nije uspjelo");

  case HTTPC_ERROR_SEND_PAYLOAD_FAILED:
    return PROGMEM("slanje podataka nije uspjelo");

  case HTTPC_ERROR_NOT_CONNECTED:
    return PROGMEM("nije povezano");

  case HTTPC_ERROR_CONNECTION_LOST:
    return PROGMEM("veza izgubljena");

  case HTTPC_ERROR_NO_STREAM:
    return PROGMEM("nema toka");

  case HTTPC_ERROR_NO_HTTP_SERVER:
    return PROGMEM("nema http poslužitelja");

  case HTTPC_ERROR_TOO_LESS_RAM:
    return PROGMEM("nema dovoljno RAM memorije");

  case HTTPC_ERROR_ENCODING:
    return PROGMEM("kodiranje nije podržano");

  case HTTPC_ERROR_STREAM_WRITE:
    return PROGMEM("greška u pisanju podataka");

  case HTTPC_ERROR_READ_TIMEOUT:
    return PROGMEM("timeout za čitanje je istekao");
  }

  return "nepoznata greška";
}
