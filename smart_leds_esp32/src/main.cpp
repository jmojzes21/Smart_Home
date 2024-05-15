
#include <Arduino.h>
#include <WiFi.h>
#include <ESPAsyncWebServer.h>
#include <ESPmDNS.h>
#include <FastLED.h>
#include <LittleFS.h>
#include <Ticker.h>

#include "device.h"
#include "led_manager.h"

#include "wifi_manager.h"
#include "rest_api.h"
#include "ota_update.h"
#include "power_sensor.h"

#include "settings.h"
#include "log.h"

const char* firmwareVersion = "v0.2.0";
const char* deviceHostname = "smart_leds";
const char* deviceType = "Smart LEDs L24";
const int httpPort = 80;

Device device;
LedDriver ledDriver;
LedManager ledManager;

WifiManager wifiManager;
AsyncWebServer httpServer(httpPort);
DeviceRestApi restApi;
OtaUpdate otaUpdate;
PowerSensor powerSensor;

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
    ledManager.setup();

    // postavi senzor struje
    powerSensor.setup();

    // postavi wifi manager
    wifiManager.setup();

    // postavi rest api
    restApi.setup();

    // postavi ota update
    otaUpdate.setup();

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
    ledManager.loop();
}
