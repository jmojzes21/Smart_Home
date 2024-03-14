
#include "rest_api.h"
#include "log.h"

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

void DeviceRestApi::setup(AsyncWebServer* httpServer, Device* device, PatternManager* patternManager, VoidCallback onRestart) {
    
    _httpServer = httpServer;
    _device = device;
    _patternManager = patternManager;
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

    // POST /pattern
    // PUT /pattern

    auto patternHandler = new AsyncCallbackJsonWebHandler("/pattern", nullptr);
    patternHandler->setMethod(HTTP_POST | HTTP_PUT);
    patternHandler->onRequest([&](AsyncWebServerRequest* request, JsonVariant& json) {

        auto method = request->method();
        JsonObject pattern = json.as<JsonObject>();

        bool result;
        if(method == HTTP_POST) {
            result = _patternManager->changePattern(pattern);
        }else{
            result = _patternManager->updatePattern(pattern);
        }

        if(result) {
            respondMessage(request, 201, "Ok");
        }else{
            respondMessage(request, 400, "Error");
        }

    });
    _httpServer->addHandler(patternHandler);


    // GET /logs

    _httpServer->on("/logs", HTTP_GET, [&](AsyncWebServerRequest* req) {
        std::string logs = qlog_get_logs();
        req->send(200, "text/plain", logs.c_str());
    });

    // DELETE /logs

    _httpServer->on("/logs", HTTP_DELETE, [&](AsyncWebServerRequest* req) {
        qlog_clear();
        req->send(201);
    });

    // POST /restart

    _httpServer->on("/restart", HTTP_POST, [&](AsyncWebServerRequest* req) {
        respondMessage(req, 201, "Ok");
        _onRestart();
    });

}
