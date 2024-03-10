
#include "rest_api.h"

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

void DeviceRestApi::setup(AsyncWebServer* httpServer, Device* device, VoidCallback onRestart) {
    
    _httpServer = httpServer;
    _device = device;
    _onRestart = onRestart;

    // GET /device

    _httpServer->on("/device", HTTP_GET, [&](AsyncWebServerRequest* req) {

        AsyncResponseStream* res = req->beginResponseStream("application/json");
        
        JsonDocument doc;
        doc["name"] = _device->name;
        doc["version"] = _device->version;
        doc["type"] = _device->deviceType;

        doc["ip"] = WiFi.localIP().toString();
        doc["mac"] = WiFi.macAddress();
        doc["ssid"] = WiFi.SSID();

        serializeJson(doc, *res);
        req->send(res);
    });

    // POST /restart

    _httpServer->on("/restart", HTTP_POST, [&](AsyncWebServerRequest* req) {
        respondMessage(req, 201, "Ok");
        _onRestart();
    });

}
