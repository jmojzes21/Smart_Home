
#include <Arduino.h>
#include <WiFi.h>
#include <ESPAsyncWebServer.h>
#include <ESPmDNS.h>
#include <FastLED.h>
#include <Adafruit_INA219.h>
#include <LittleFS.h>
#include <Ticker.h>

#include "device.h"
#include "pattern_manager.h"

#include "wifi_manager.h"
#include "rest_api.h"
#include "ota_update.h"

#include "settings.h"
#include "log.h"

const char* firmwareVersion = "0.0.2";
const char* deviceHostname = "smart_leds";
const char* deviceType = "Smart LEDs L24";
const int httpPort = 80;

Device device;
PatternManager patternManager;

WifiManager wifiManager;
AsyncWebServer httpServer(httpPort);
DeviceRestApi restApi;
OtaUpdate otaUpdate;
Adafruit_INA219 powerSensor;

Ticker restartTicker;
void requestRestart();

Ticker powerSensorTicker;

void setup() {

    #ifdef SERIAL_DEBUG
    Serial.begin(115200);
    #endif

    qlog_setup(2048);

    // učitaj postavke
    qlog("Učitaj postavke");

    LittleFS.begin(true);
    Settings settings;
    settings.load();

    // postavi device

    device.name = settings.deviceName;
    device.password = settings.devicePassword;

    device.version = firmwareVersion;
    device.deviceType = deviceType;

    qlog("Uređaj naziv: %s, verzija: %s, tip: %s", device.name.c_str(), device.version, device.deviceType);

    // postavi FastLED
    patternManager.setup();

    // postavi senzor struje
    powerSensor.begin();

    // postavi wifi manager
    wifiManager.setup(&device);

    // postavi rest api
    restApi.setup(&httpServer, &device, &patternManager, requestRestart);

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

    // temp
    powerSensorTicker.attach_ms(4000, []() {
        float current_mA = powerSensor.getCurrent_mA();
        Serial.printf("I: %.1f mA\n", current_mA);
    });

}

void loop() {
    patternManager.loop();
}

void requestRestart() {
    restartTicker.once_ms(2000, []() {
        ESP.restart();
    });
}
