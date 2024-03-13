
#include <Arduino.h>
#include <WiFi.h>
#include <ESPAsyncWebServer.h>
#include <ESPmDNS.h>
#include <FastLED.h>
#include <Adafruit_INA219.h>
#include <LittleFS.h>
#include <Ticker.h>

#include "device.h"

#include "wifi_manager.h"
#include "rest_api.h"
#include "ota_update.h"

#include "settings.h"
#include "log.h"

const char* firmwareVersion = "0.0.2";
const char* deviceHostname = "smart_leds";
const char* deviceType = "Smart LEDs L24";
const int httpPort = 80;
const int ledDataPin = 26;

Device device;

const int ledCount = 7;
CRGB leds[ledCount];

WifiManager wifiManager;
AsyncWebServer httpServer(httpPort);
DeviceRestApi restApi;
OtaUpdate otaUpdate;
Adafruit_INA219 powerSensor;

Ticker restartTicker;
void requestRestart();

void setup() {

    Serial.begin(115200);
    Log.setup(2048);

    // učitaj postavke
    Log.info("Učitaj postavke\n");

    LittleFS.begin(true);
    Settings settings;
    settings.load();

    // postavi device

    device.name = settings.deviceName;
    device.password = settings.devicePassword;

    device.version = firmwareVersion;
    device.deviceType = deviceType;

    Log.info("Uređaj naziv: %s, verzija: %s, tip: %s\n", device.name.c_str(), device.version, device.deviceType);

    // postavi FastLED
    FastLED.addLeds<WS2812B, ledDataPin, GRB>(leds, ledCount);
    FastLED.clear(true);
    FastLED.setBrightness(40);

    leds[0] = CRGB::Green;
    FastLED.show();

    // postavi senzor struje
    powerSensor.begin();

    // postavi wifi manager
    wifiManager.setup(&device);

    // postavi rest api
    restApi.setup(&httpServer, &device, requestRestart);

    // postavi ota update
    otaUpdate.setup(&httpServer, &device, requestRestart);

    // poveži se na wifi mrežu
    wifiManager.connectToWifi();

    // postavi mdns
    MDNS.begin(deviceHostname);
    MDNS.setInstanceName(device.name.c_str());
    MDNS.addService("http", "tcp", httpPort);

    // pokreni http server
    httpServer.begin();

}

void loop() {

    float shuntvoltage = 0;
    float busvoltage = 0;
    float current_mA = 0;
    float loadvoltage = 0;
    float power_mW = 0;

    shuntvoltage = powerSensor.getShuntVoltage_mV();
    busvoltage = powerSensor.getBusVoltage_V();
    current_mA = powerSensor.getCurrent_mA();
    power_mW = powerSensor.getPower_mW();
    loadvoltage = busvoltage + (shuntvoltage / 1000);
    
    Serial.print("Bus Voltage:   "); Serial.print(busvoltage); Serial.println(" V");
    Serial.print("Shunt Voltage: "); Serial.print(shuntvoltage); Serial.println(" mV");
    Serial.print("Load Voltage:  "); Serial.print(loadvoltage); Serial.println(" V");
    Serial.print("Current:       "); Serial.print(current_mA); Serial.println(" mA");
    Serial.print("Power:         "); Serial.print(power_mW); Serial.println(" mW");
    Serial.println("");

    delay(2000);
}

void requestRestart() {
    restartTicker.once_ms(2000, []() {
        ESP.restart();
    });
}
