
#include "SensorController.h"

#include <LedColors.h>

#define PMS_RX_PIN 14
#define PMS_TX_PIN 15
#define VIN_ADC_PIN 35

#define SAVE_AQ_HISTORY_PERIOD 60000

SensorController::SensorController(DeviceController* deviceController) {
  this->deviceController = deviceController;
}

void SensorController::init() {

  memset(&pms5003Data, 0, sizeof(pms5003Data));

  i2cSensorMutex = xSemaphoreCreateMutex();
  pmsMutex = xSemaphoreCreateMutex();
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

  xTaskCreateUniversal(pmsTask, "pmsTask", 8192, this, 1, &pmsTaskHandle, ARDUINO_RUNNING_CORE);
  xTaskCreateUniversal(aqHistoryTask, "aqHistory", 8192, this, 1, &aqHistoryTaskHandle, ARDUINO_RUNNING_CORE);

}

void SensorController::readSensorData(AirQualityData& aqData) {

  Bme280SensorData& bme280Data = aqData.bme280;
  Shtc3SensorData& shtc3Data = aqData.shtc3;

  xSemaphoreTake(i2cSensorMutex, portMAX_DELAY);

  bme280Data.temperature = bme280Sensor.readTemperature();
  bme280Data.humidity = bme280Sensor.readHumidity();
  bme280Data.pressure = bme280Sensor.readPressure() / 100.0f;

  shtc3Sensor.sample();
  shtc3Data.temperature = shtc3Sensor.readTempC();
  shtc3Data.humidity = shtc3Sensor.readHumidity();

  xSemaphoreGive(i2cSensorMutex);

  xSemaphoreTake(pmsMutex, portMAX_DELAY);
  aqData.pms = pms5003Data;
  xSemaphoreGive(pmsMutex);
  
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

  AirQualityData aqData;
  readSensorData(aqData);

  AirQualityHistory aqHistory;
  aqHistory.time = millis() / 1000;

  aqHistory.temperature = (aqData.bme280.temperature + aqData.shtc3.temperature) / 2;
  aqHistory.humidity = (aqData.bme280.humidity + aqData.shtc3.humidity) / 2;
  aqHistory.pressure = aqData.bme280.pressure;
  aqHistory.pm25 = aqData.pms.pm_25_env;

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

std::list<AirQualityHistory>& SensorController::getAirQualityHistory() {
  return aqHistoryList;
}

void pmsTask(void* param) {

  auto sensorController = (SensorController*)param;
  
  PMS5003_Sensor& pms5003Sensor = sensorController->pms5003Sensor;
  PMS5003_Data tdata;

  SemaphoreHandle_t pmsMutex = sensorController->pmsMutex;

  while(true) {
    if(pms5003Sensor.read(&tdata)) {
      xSemaphoreTake(pmsMutex, portMAX_DELAY);
      sensorController->pms5003Data = tdata;
      xSemaphoreGive(pmsMutex);
    }
    
    delay(2000);
  }

}

void aqHistoryTask(void* param) {

  auto sensorController = (SensorController*)param;

  sensorController->saveAqHistoryTime = millis() + SAVE_AQ_HISTORY_PERIOD;

  while(true) {
    
    uint64_t now = millis();
    if(now >= sensorController->saveAqHistoryTime) {
      sensorController->saveAqHistoryTime = now + SAVE_AQ_HISTORY_PERIOD;
      sensorController->saveAirQualityHistory();
    }

    delay(2000);
  }

}
