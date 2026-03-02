
#include "SensorController.h"

#include <LedColors.h>
#include "helpers/DateFormats.h"

#define PMS_RX_PIN 14
#define PMS_TX_PIN 15
#define VIN_ADC_PIN 35

#define READ_SENSOR_DELAY 2000

void readAirQualityTask(void* param);
void aqHistoryTask(void* param);

SensorController::SensorController(DeviceController* deviceController) {
  this->deviceController = deviceController;
}

void SensorController::init() {

  memset(&aqData.pms, 0, sizeof(PMS5003_Data));

  aqDataMutex = xSemaphoreCreateMutex();
  aqRecentHistoryMutex = xSemaphoreCreateMutex();
  vinAdcMutex = xSemaphoreCreateMutex();

  if(!bme280Sensor.begin(BME280_ADDRESS_ALTERNATE)) {
    log_e("Can't init BME280 sensor");
    deviceController->showColor(LedColors::Orange);
    deviceController->haltDevice();
  }

  if(!shtc3Sensor.begin()) {
    log_e("Can't init SHTC3 sensor");
    deviceController->showColor(LedColors::Orange);
    deviceController->haltDevice();
  }

  pms5003Sensor.init(&Serial2, PMS_RX_PIN, PMS_TX_PIN);

  pinMode(VIN_ADC_PIN, INPUT);

  xTaskCreateUniversal(readAirQualityTask, "aqTask", 8192, this, 1, &pmsTaskHandle, ARDUINO_RUNNING_CORE);
  xTaskCreateUniversal(aqHistoryTask, "aqHistory", 8192, this, 1, &aqHistoryTaskHandle, ARDUINO_RUNNING_CORE);

}

DeviceController *SensorController::getDeviceController() {
  return deviceController;
}

AirQualityData SensorController::getAirQuality() {

  AirQualityData aq;

  xSemaphoreTake(aqDataMutex, portMAX_DELAY);
  aq = this->aqData;
  xSemaphoreGive(aqDataMutex);

  return aq;
}

void SensorController::readSensorData() {

  auto& bme280Data = aqData.bme280;
  auto& shtc3Data = aqData.shtc3;

  xSemaphoreTake(aqDataMutex, portMAX_DELAY);

  bme280Data.temperature = bme280Sensor.readTemperature();
  bme280Data.humidity = bme280Sensor.readHumidity();
  bme280Data.pressure = bme280Sensor.readPressure() / 100.0f;

  shtc3Sensor.sample();
  shtc3Data.temperature = shtc3Sensor.readTempC();
  shtc3Data.humidity = shtc3Sensor.readHumidity();

  aqData.temperature = (bme280Data.temperature + shtc3Data.temperature) / 2.0;
  aqData.humidity = (bme280Data.humidity + shtc3Data.humidity) / 2.0;
  aqData.pressure = bme280Data.pressure;

  recentAqMetrics.temperatureMetrics.addValue(aqData.temperature);
  recentAqMetrics.humidityMetrics.addValue(aqData.humidity);
  recentAqMetrics.pressureMetrics.addValue(aqData.pressure);

  historyAqMetrics.temperatureMetrics.addValue(aqData.temperature);
  historyAqMetrics.humidityMetrics.addValue(aqData.humidity);
  historyAqMetrics.pressureMetrics.addValue(aqData.pressure);

  xSemaphoreGive(aqDataMutex);

  PMS5003_Data pmsTemp;
  if(pms5003Sensor.read(&pmsTemp)) {

    xSemaphoreTake(aqDataMutex, portMAX_DELAY);

    aqData.pms = pmsTemp;
    recentAqMetrics.pm25Metrics.addValue(aqData.pms.pm_25_env);
    historyAqMetrics.pm25Metrics.addValue(aqData.pms.pm_25_env);

    xSemaphoreGive(aqDataMutex);

  }
  
  if(onSensorData != nullptr) {
    AirQualityData aqData2 = getAirQuality();
    onSensorData(aqData2);
  }
  
}

uint32_t SensorController::readInputVoltage() {

  xSemaphoreTake(vinAdcMutex, portMAX_DELAY);

  uint32_t adcVoltage = 0;
  for(int i = 0; i < 8; i++) {
    adcVoltage += analogReadMilliVolts(VIN_ADC_PIN);
  }

  xSemaphoreGive(vinAdcMutex);
  
  adcVoltage /= 8;
  uint32_t voltage = 2.0f * adcVoltage;

  return voltage;
}

void SensorController::saveRecentHistory() {

  uint32_t timeSeconds = (uint32_t)millis() / 1000;

  AirQualityHistory aqHistory;
  aqHistory.timeSeconds = timeSeconds;

  xSemaphoreTake(aqDataMutex, portMAX_DELAY);

  aqHistory.temperatureMetrics = recentAqMetrics.temperatureMetrics;
  aqHistory.humidityMetrics = recentAqMetrics.humidityMetrics;
  aqHistory.pressureMetrics = recentAqMetrics.pressureMetrics;
  aqHistory.pm25Metrics = recentAqMetrics.pm25Metrics;

  recentAqMetrics.reset();

  xSemaphoreGive(aqDataMutex);

  aqHistory.temperatureMetrics.calculateAverage();
  aqHistory.humidityMetrics.calculateAverage();
  aqHistory.pressureMetrics.calculateAverage();
  aqHistory.pm25Metrics.calculateAverage();

  takeRecentHistoryMutex();

  while(aqRecentHistoryList.size() >= 400) {
    aqRecentHistoryList.pop_front();
  }

  aqRecentHistoryList.push_back(aqHistory);

  giveRecentHistoryMutex();

}

void SensorController::saveHistory() {

  AirQualityHistory aqHistory;

  xSemaphoreTake(aqDataMutex, portMAX_DELAY);

  aqHistory.temperatureMetrics = historyAqMetrics.temperatureMetrics;
  aqHistory.humidityMetrics = historyAqMetrics.humidityMetrics;
  aqHistory.pressureMetrics = historyAqMetrics.pressureMetrics;
  aqHistory.pm25Metrics = historyAqMetrics.pm25Metrics;

  historyAqMetrics.reset();

  xSemaphoreGive(aqDataMutex);

  aqHistory.temperatureMetrics.calculateAverage();
  aqHistory.humidityMetrics.calculateAverage();
  aqHistory.pressureMetrics.calculateAverage();
  aqHistory.pm25Metrics.calculateAverage();

  struct tm currentTime = deviceController->getDateTime();

  if(onSaveHistoryData != nullptr) {
    onSaveHistoryData(currentTime, aqHistory);
  }

}

void SensorController::takeRecentHistoryMutex() {
  xSemaphoreTake(aqRecentHistoryMutex, portMAX_DELAY);
}

void SensorController::giveRecentHistoryMutex() {
  xSemaphoreGive(aqRecentHistoryMutex);
}

void SensorController::clearRecentHistory() {
  takeRecentHistoryMutex();
  aqRecentHistoryList.clear();
  giveRecentHistoryMutex();
}

std::list<AirQualityHistory>& SensorController::getRecentHistory() {
  return aqRecentHistoryList;
}

void SensorController::setOnSensorData(SensorDataHandler handler) {
  onSensorData = handler;
}

void SensorController::setOnSaveHistoryData(SaveHistoryDataHandler handler) {
  onSaveHistoryData = handler;
}

void readAirQualityTask(void* param) {

  auto sensorController = (SensorController*)param;

  while(true) {
    sensorController->readSensorData();
    delay(READ_SENSOR_DELAY);
  }

}

void aqHistoryTask(void* param) {

  auto sensorController = (SensorController*)param;
  auto deviceController = sensorController->getDeviceController();

  auto& config = deviceController->getConfig();
  uint32_t saveRecentPeriod = config.recentDataPeriod * 1000;
  uint32_t saveHistoryPeriod = config.historyDataPeriod * 1000;

  uint32_t t1 = millis() + saveRecentPeriod;
  uint32_t t2 = millis() + saveHistoryPeriod;

  while(true) {

    uint32_t now = millis();
    if(now >= t1) {
      t1 = now + saveRecentPeriod;
      sensorController->saveRecentHistory();
    }

    now = millis();
    if(now >= t2) {
      t2 = now + saveHistoryPeriod;
      sensorController->saveHistory();
    }

    delay(2000);

  }

}

void AirQualityMetrics::reset() {
  temperatureMetrics.reset();
  humidityMetrics.reset();
  pressureMetrics.reset();
  pm25Metrics.reset();
}
