
#include <AsyncJson.h>

#include "rest_api.h"
#include "log.h"

extern AsyncWebServer httpServer;
extern Device device;
extern LedManager ledManager;
extern VoidCallback onDeviceRestart;

void respondJson(AsyncWebServerRequest* request, int code, JsonDocument& doc) {
    AsyncResponseStream* response = request->beginResponseStream("application/json");
    response->setCode(code);

    serializeJson(doc, *response);
    request->send(response);
}

void respondMessage(AsyncWebServerRequest* request, int code, const char* message) {
    JsonDocument doc;
    doc["msg"] = message;

    respondJson(request, code, doc);
}

void DeviceRestApi::setup() {
    
    // GET /device

    httpServer.on("/device", HTTP_GET, [&](AsyncWebServerRequest* req) {

        AsyncResponseStream* res = req->beginResponseStream("application/json");
        
        JsonDocument doc;
        doc["name"] = device.name;
        doc["version"] = device.version;
        doc["type"] = device.deviceType;

        doc["ip"] = WiFi.localIP().toString();
        doc["mac"] = WiFi.macAddress();
        doc["ssid"] = WiFi.SSID();

        serializeJson(doc, *res);
        req->send(res);
    });

    // POST /pattern

    auto patternHandler = new AsyncCallbackJsonWebHandler("/pattern", nullptr);
    patternHandler->setMethod(HTTP_POST);
    patternHandler->onRequest([&](AsyncWebServerRequest* request, JsonVariant& json) {
        JsonObject p = json.as<JsonObject>();
        bool result = ledManager.updatePattern(p);
        request->send(result ? 201 : 400);
    });
    httpServer.addHandler(patternHandler);

    // POST /brightness

    auto brightnessHandler = new AsyncCallbackJsonWebHandler("/brightness", nullptr);
    brightnessHandler->setMethod(HTTP_POST);
    brightnessHandler->onRequest([&](AsyncWebServerRequest* request, JsonVariant& json) {

        JsonObject object = json.as<JsonObject>();
        int value = object["value"];

        if(value < 0 || value > 255) {
            request->send(400);
            return;
        }

        ledManager.setBrightness(value);
        request->send(201);
    });
    httpServer.addHandler(brightnessHandler);

    // GET /logs

    httpServer.on("/logs", HTTP_GET, [&](AsyncWebServerRequest* req) {
        std::string logs = qlog_get_logs();
        req->send(200, "text/plain", logs.c_str());
    });

    // DELETE /logs

    httpServer.on("/logs", HTTP_DELETE, [&](AsyncWebServerRequest* req) {
        qlog_clear();
        req->send(201);
    });

    // POST /enable_direct_access
    httpServer.on("/enable_direct_access", HTTP_POST, [&](AsyncWebServerRequest* req) {
        bool result = ledManager.enableDirectAccess();
        req->send(result ? 201 : 400);
    });

    // POST /restart

    httpServer.on("/restart", HTTP_POST, [&](AsyncWebServerRequest* req) {
        respondMessage(req, 201, "Ok");
        onDeviceRestart();
    });

}
