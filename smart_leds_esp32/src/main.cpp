
#include <Arduino.h>
#include <WiFi.h>
#include <ESPAsyncWebServer.h>
#include <ArduinoJson.h>
#include <AsyncJson.h>
#include <ESPmDNS.h>
#include <LittleFS.h>

#include "rest_common.h"
#include "ota_update.h"

const char* firmwareVersion = "0.0.2_B8";
const char* deviceHostname = "smart_leds";
const char* deviceType = "Smart LEDs L24";
const char* deviceName = "Moje pametne LEDice";
const int httpPort = 80;

AsyncWebServer httpServer(httpPort);
OtaUpdate otaUpdate;

void connectToWiFi();
void setupMdns();
void setupRestApi();

void setup() {

    Serial.begin(115200);
    Serial.println("Smart LEDs");

    //LittleFS.begin(true);

    connectToWiFi();
    setupRestApi();
    setupMdns();

    otaUpdate.setup(&httpServer, deviceType);
    httpServer.begin();

}

void loop() {

}

void setupRestApi() {

    httpServer.on("/device", HTTP_GET, [](AsyncWebServerRequest* req) {

        AsyncResponseStream* res = req->beginResponseStream("application/json");
        
        JsonDocument doc;
        doc["name"] = deviceName;
        doc["version"] = firmwareVersion;
        doc["type"] = deviceType;
        doc["ip"] = WiFi.localIP().toString();
        doc["mac"] = WiFi.macAddress();
        doc["ssid"] = WiFi.SSID();
        doc["rssi"] = WiFi.RSSI();

        serializeJson(doc, *res);
        req->send(res);
    });

    static Ticker _restartTicker;
    httpServer.on("/restart", HTTP_POST, [](AsyncWebServerRequest* req) {
        respondMessage(req, 201, "Ok");
        _restartTicker.once_ms(2000, []() {
            ESP.restart();
        });
    });

}

void connectToWiFi() {

    // učitaj wifi postavke

    LittleFS.begin(true);

    File f = LittleFS.open("/wifi", FILE_READ);

    String ssid = f.readStringUntil('\n');
    String pass = f.readStringUntil('\n');

    ssid.trim();
    pass.trim();

    f.close();

    LittleFS.end();

    // poveži se

    log_i("Poveži se na WiFi mrežu: %s (%s)", ssid.c_str(), pass.c_str());

    WiFi.disconnect(true);
    WiFi.begin(ssid, pass);
    
    uint32_t start = millis();
    while(WiFi.status() != WL_CONNECTED) {
        delay(100);
    }
    uint32_t end = millis();

    Serial.println();
    Serial.printf("WIFI CONNECT Elapsed %d ms\n", (int)(end - start));
    log_i("Povezano, IP: %s", WiFi.localIP().toString().c_str());

}

void setupMdns() {
    MDNS.begin(deviceHostname);
    MDNS.setInstanceName(deviceName);
    MDNS.addService("http", "tcp", httpPort);
}
