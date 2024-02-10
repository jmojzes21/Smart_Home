
#define CORE_DEBUG_LEVEL 4

#include <Arduino.h>
#include <WiFi.h>
#include <ESPAsyncWebServer.h>
#include <ArduinoJson.h>
#include <ESPmDNS.h>
#include <LittleFS.h>

const char* firmwareVersion = "0.0.1";
const char* deviceHostname = "smart_leds";
const char* deviceName = "Moje pametne LEDice";
const int httpPort = 80;

AsyncWebServer httpServer(httpPort);

void connectToWiFi();
void setupMdns();
void setupRestApi();

void setup() {

    Serial.begin(115200);
    Serial.println("Smart LEDs");

    LittleFS.begin(true);

    connectToWiFi();
    setupRestApi();
    setupMdns();

}

void loop() {

}

void setupRestApi() {

    httpServer.on("/device", HTTP_GET, [](AsyncWebServerRequest* req) {

        AsyncResponseStream* res = req->beginResponseStream("application/json");
        
        JsonDocument doc;
        doc["name"] = deviceName;
        doc["version"] = firmwareVersion;
        doc["ip"] = WiFi.localIP().toString();
        doc["mac"] = WiFi.macAddress();
        doc["ssid"] = WiFi.SSID();
        doc["rssi"] = WiFi.RSSI();

        serializeJson(doc, *res);
        req->send(res);
    });

    httpServer.begin();

}

void connectToWiFi() {

    // učitaj wifi postavke

    File f = LittleFS.open("/wifi", FILE_READ);

    String ssid = f.readStringUntil('\n');
    String pass = f.readStringUntil('\n');

    ssid.trim();
    pass.trim();

    f.close();

    // poveži se

    log_i("Poveži se na WiFi mrežu: %s (%s)", ssid.c_str(), pass.c_str());

    WiFi.begin(ssid, pass);
    uint32_t start = millis();
    while(WiFi.status() != WL_CONNECTED) {
        delay(10);
    }
    uint32_t end = millis();

    Serial.printf("WIFI CONNECT Elapsed %d ms\n", (int)(end - start));
    log_i("Povezano, IP: %s", WiFi.localIP().toString().c_str());

}

void setupMdns() {
    MDNS.begin(deviceHostname);
    MDNS.setInstanceName(deviceName);
    MDNS.addService("http", "tcp", httpPort);
}
