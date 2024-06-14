
#include "power_sensor.h"
#include "log.h"

void PowerSensor::setup() {

    _mutex = xSemaphoreCreateMutex();
    _ina219.begin();

}

void _powerSensorTask(void* p) {

    PowerSensor* powerSensor = (PowerSensor*)p;
    
    while(true) {

        xSemaphoreTake(powerSensor->_mutex, portMAX_DELAY);
        
        bool active = powerSensor->_isActive;
        
        if(active) {

            float current;
            float voltage;

            current = powerSensor->_ina219.getCurrent_mA();
            voltage = powerSensor->_ina219.getBusVoltage_V();

            PowerSensorData& data = powerSensor->_data;
            
            data.current = current;
            if(current < data.minCurrent) data.minCurrent = current;
            else if(current > data.maxCurrent) data.maxCurrent = current;

            data.voltage = voltage;
            if(voltage < data.minVoltage) data.minVoltage = voltage;
            else if(voltage > data.maxVoltage) data.maxVoltage = voltage;

        }
        
        xSemaphoreGive(powerSensor->_mutex);

        if(active == false) {
            vTaskDelete(nullptr);
            return;
        }

        delay(2000);

    }

}

bool PowerSensor::isActive() {

    xSemaphoreTake(_mutex, portMAX_DELAY);
    bool active = _isActive;
    xSemaphoreGive(_mutex);

    return active;
}

void PowerSensor::setActive(bool active) {

    xSemaphoreTake(_mutex, portMAX_DELAY);

    if(active == _isActive) return;
    _isActive = active;
    
    if(_isActive) {
        // pokreni senzor

        _data.current = 0;
        _data.minCurrent = 10000;
        _data.maxCurrent = 0;

        _data.voltage = 0;
        _data.minVoltage = 100;
        _data.maxVoltage = 0;

        xTaskCreateUniversal(_powerSensorTask, "power_sensor", 8192, this, 2, &_sensorTask, ARDUINO_RUNNING_CORE);

    }

    xSemaphoreGive(_mutex);

}

void PowerSensor::getData(PowerSensorData* data) {

    xSemaphoreTake(_mutex, portMAX_DELAY);

    data->current = _data.current;
    data->minCurrent = _data.minCurrent;
    data->maxCurrent = _data.maxCurrent;

    data->voltage = _data.voltage;
    data->minVoltage = _data.minVoltage;
    data->maxVoltage = _data.maxVoltage;
    
    xSemaphoreGive(_mutex);

}
