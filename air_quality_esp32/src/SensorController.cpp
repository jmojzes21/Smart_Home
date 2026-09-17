
#include "SensorController.h"

#include <LedColors.h>

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

  // read temperature, humidity, pressure

  xSemaphoreTake(aqDataMutex, portMAX_DELAY);

  // bme280
  bme280Data.temperature = bme280Sensor.readTemperature();
  bme280Data.humidity = bme280Sensor.readHumidity();
  bme280Data.pressure = bme280Sensor.readPressure() / 100.0f;

  // shtc3
  shtc3Sensor.sample();
  shtc3Data.temperature = shtc3Sensor.readTempC();
  shtc3Data.humidity = shtc3Sensor.readHumidity();

  // set current data
  aqData.temperature = (bme280Data.temperature + shtc3Data.temperature) / 2.0;
  aqData.humidity = (bme280Data.humidity + shtc3Data.humidity) / 2.0;
  aqData.pressure = bme280Data.pressure;

  // add to recent and aqm metrics

  recentAqMetrics.temperatureMetrics.addValue(aqData.temperature);
  recentAqMetrics.humidityMetrics.addValue(aqData.humidity);
  recentAqMetrics.pressureMetrics.addValue(aqData.pressure);

  aqmMetrics.temperatureMetrics.addValue(aqData.temperature);
  aqmMetrics.humidityMetrics.addValue(aqData.humidity);
  aqmMetrics.pressureMetrics.addValue(aqData.pressure);

  xSemaphoreGive(aqDataMutex);

  // read PM.25, PM10

  PMS5003_Data pmsTemp;
  if(pms5003Sensor.read(&pmsTemp)) {

    xSemaphoreTake(aqDataMutex, portMAX_DELAY);

    aqData.pms = pmsTemp;

    // add to recent and aqm metrics

    recentAqMetrics.pm2p5Metrics.addValue(aqData.pms.pm_25_env);
    recentAqMetrics.pm10Metrics.addValue(aqData.pms.pm_100_env);

    aqmMetrics.pm2p5Metrics.addValue(aqData.pms.pm_25_env);
    aqmMetrics.pm10Metrics.addValue(aqData.pms.pm_100_env);

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
    delay(10);
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

  // get metrics

  xSemaphoreTake(aqDataMutex, portMAX_DELAY);

  aqHistory.temperatureMetrics = recentAqMetrics.temperatureMetrics;
  aqHistory.humidityMetrics = recentAqMetrics.humidityMetrics;
  aqHistory.pressureMetrics = recentAqMetrics.pressureMetrics;

  aqHistory.pm2p5Metrics = recentAqMetrics.pm2p5Metrics;
  aqHistory.pm10Metrics = recentAqMetrics.pm10Metrics;

  recentAqMetrics.reset();

  xSemaphoreGive(aqDataMutex);

  // calculate average

  aqHistory.temperatureMetrics.calculateAverage();
  aqHistory.humidityMetrics.calculateAverage();
  aqHistory.pressureMetrics.calculateAverage();

  aqHistory.pm2p5Metrics.calculateAverage();
  aqHistory.pm10Metrics.calculateAverage();

  takeRecentHistoryMutex();

  while(aqRecentHistoryList.size() >= 400) {
    aqRecentHistoryList.pop_front();
  }

  aqRecentHistoryList.push_back(aqHistory);

  giveRecentHistoryMutex();

}

void SensorController::saveDataAqm() {

  auto& config = deviceController->getAqmConfig();
  if(!config.saveMeasurements) return;

  AirQualityHistory measurement;

  // get metrics

  xSemaphoreTake(aqDataMutex, portMAX_DELAY);

  measurement.temperatureMetrics = aqmMetrics.temperatureMetrics;
  measurement.humidityMetrics = aqmMetrics.humidityMetrics;
  measurement.pressureMetrics = aqmMetrics.pressureMetrics;

  measurement.pm2p5Metrics = aqmMetrics.pm2p5Metrics;
  measurement.pm10Metrics = aqmMetrics.pm10Metrics;

  aqmMetrics.reset();

  xSemaphoreGive(aqDataMutex);

  // calculate average

  measurement.temperatureMetrics.calculateAverage();
  measurement.humidityMetrics.calculateAverage();
  measurement.pressureMetrics.calculateAverage();

  measurement.pm2p5Metrics.calculateAverage();
  measurement.pm10Metrics.calculateAverage();

  DateTime currentTime = deviceController->getDateTime();

  if(onSaveDataAqm != nullptr) {
    onSaveDataAqm(currentTime, measurement);
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

void SensorController::setOnSaveDataAqm(SaveDataAqmHandler handler) {
  onSaveDataAqm = handler;
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
  uint32_t aqmSavePeriod = config.aqmConfig.measurementPeriod * 1000;

  uint32_t t1 = millis() + saveRecentPeriod;
  uint32_t t2 = millis() + aqmSavePeriod;

  while(true) {

    uint32_t now = millis();
    if(now >= t1) {
      t1 = now + saveRecentPeriod;
      sensorController->saveRecentHistory();
    }

    now = millis();
    if(now >= t2) {
      t2 = now + aqmSavePeriod;
      sensorController->saveDataAqm();
    }

    delay(2000);

  }

}

void AirQualityMetrics::reset() {
  temperatureMetrics.reset();
  humidityMetrics.reset();
  pressureMetrics.reset();

  pm2p5Metrics.reset();
  pm10Metrics.reset();
}
