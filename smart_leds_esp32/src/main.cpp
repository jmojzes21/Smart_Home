
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

#define MDNS_SERVICE "smart-home"

const char* firmwareVersion = "v2.0.0";
const char* deviceHostname = "smart_leds";
const char* deviceDomain = "smart-leds.local";
const char* deviceType = "smart_leds";
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

    Serial.begin(115200);
    Serial.printf("Postavi uređaj\n");

    // učitaj postavke
    LittleFS.begin(true);
    Settings settings;
    settings.load();

    // postavi device

    device.name = settings.deviceName;
    device.password = settings.devicePassword;

    device.version = firmwareVersion;
    device.deviceType = deviceType;
    device.domain = deviceDomain;

    Serial.printf("Uređaj\n");
    Serial.printf("  Naziv: %s\n", device.name.c_str());
    Serial.printf("  Tip: %s\n", device.deviceType);
    Serial.printf("  Verzija: %s\n", device.version);

    // postavi FastLED
    ledManager.setup();

    // postavi senzor struje
    powerSensor.setup();

    // postavi rest api
    restApi.setup();

    // postavi ota update
    otaUpdate.setup();

    // poveži se na wifi mrežu
    wifiManager.connectToWifi();

    // postavi mdns
    Serial.printf("Postavi mdns\n");
    MDNS.begin(deviceHostname);
    MDNS.addService(MDNS_SERVICE, "tcp", httpPort);

    // pokreni http server
    Serial.printf("Pokreni http server\n");
    httpServer.begin();

    Serial.printf("Postavljanje uređaja gotovo\n");

}

void loop() {
    ledManager.loop();
}
