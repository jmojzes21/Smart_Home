
#include <Arduino.h>
#include <WiFi.h>
#include <ESPAsyncWebServer.h>
#include <ArduinoJson.h>
#include <AsyncJson.h>
#include <ESPmDNS.h>
#include <LittleFS.h>
#include <Ticker.h>

#include "device.h"

#include "wifi_manager.h"
#include "rest_api.h"
#include "ota_update.h"

#include "settings.h"

const char* firmwareVersion = "0.0.2";
const char* deviceHostname = "smart_leds";
const char* deviceType = "Smart LEDs L24";
const int httpPort = 80;

Device device;

WifiManager wifiManager;
AsyncWebServer httpServer(httpPort);
DeviceRestApi restApi;
OtaUpdate otaUpdate;

Ticker restartTicker;
void requestRestart();

void setup() {

    Serial.begin(115200);

    // učitaj postavke

    LittleFS.begin(true);
    Settings settings;
    settings.load();

    // postavi device

    device.name = settings.deviceName;
    device.password = settings.devicePassword;

    device.version = firmwareVersion;
    device.deviceType = deviceType;

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

}

void requestRestart() {
    restartTicker.once_ms(2000, []() {
        ESP.restart();
    });
}
