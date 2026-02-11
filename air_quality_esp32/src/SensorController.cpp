
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
  aqHistoryMutex = xSemaphoreCreateMutex();
  vinAdcMutex = xSemaphoreCreateMutex();

  if(!bme280Sensor.begin(BME280_ADDRESS_ALTERNATE)) {
    deviceController->showColor(LedColors::Orange);
    deviceController->haltDevice();
  }

  if(!shtc3Sensor.begin()) {
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

  aqMetrics.temperatureMetrics.addValue(aqData.temperature);
  aqMetrics.humidityMetrics.addValue(aqData.humidity);
  aqMetrics.pressureMetrics.addValue(aqData.pressure);

  xSemaphoreGive(aqDataMutex);

  PMS5003_Data pmsTemp;
  if(pms5003Sensor.read(&pmsTemp)) {

    xSemaphoreTake(aqDataMutex, portMAX_DELAY);

    aqData.pms = pmsTemp;
    aqMetrics.pm25Metrics.addValue(aqData.pms.pm_25_env);

    xSemaphoreGive(aqDataMutex);

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

void SensorController::saveAirQualityHistory() {

  uint32_t timeSeconds = (uint32_t)millis() / 1000;

  AirQualityHistory aqHistory;
  aqHistory.timeSeconds = timeSeconds;

  xSemaphoreTake(aqDataMutex, portMAX_DELAY);

  aqHistory.temperatureMetrics = aqMetrics.temperatureMetrics;
  aqHistory.humidityMetrics = aqMetrics.humidityMetrics;
  aqHistory.pressureMetrics = aqMetrics.pressureMetrics;
  aqHistory.pm25Metrics = aqMetrics.pm25Metrics;

  aqMetrics.reset();

  xSemaphoreGive(aqDataMutex);

  aqHistory.temperatureMetrics.calculateAverage();
  aqHistory.humidityMetrics.calculateAverage();
  aqHistory.pressureMetrics.calculateAverage();
  aqHistory.pm25Metrics.calculateAverage();

  takeAqHistoryMutex();

  while(aqHistoryList.size() >= 400) {
    aqHistoryList.pop_front();
  }

  aqHistoryList.push_back(aqHistory);

  giveAqHistoryMutex();

}

void SensorController::takeAqHistoryMutex() {
  xSemaphoreTake(aqHistoryMutex, portMAX_DELAY);
}

void SensorController::giveAqHistoryMutex() {
  xSemaphoreGive(aqHistoryMutex);
}

void SensorController::clearAirQualityHistory() {
  takeAqHistoryMutex();
  aqHistoryList.clear();
  giveAqHistoryMutex();
}

std::list<AirQualityHistory>& SensorController::getAirQualityHistory() {
  return aqHistoryList;
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

  uint32_t savePeriod = deviceController->getConfig().recentHistoryPeriod;
  uint32_t t1 = millis() + savePeriod;

  while(true) {

    uint32_t t2 = millis();
    if(t2 >= t1) {
      t1 = t2 + savePeriod;
      sensorController->saveAirQualityHistory();
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
