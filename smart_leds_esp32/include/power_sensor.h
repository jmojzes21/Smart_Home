
#pragma once

#include <Arduino.h>
#include <Adafruit_INA219.h>

struct PowerSensorData {

    float current;
    float minCurrent;
    float maxCurrent;

    float voltage;
    float minVoltage;
    float maxVoltage;

};

void _powerSensorTask(void* p);

class PowerSensor {

    private:

    Adafruit_INA219 _ina219;
    PowerSensorData _data;

    bool _isActive = false;
    TaskHandle_t _sensorTask = nullptr;
    SemaphoreHandle_t _mutex;
    
    friend void _powerSensorTask(void* p);

    public:

    void setup();
    
    bool isActive();
    void setActive(bool active);
    void getData(PowerSensorData* data);
    
    private:

};
