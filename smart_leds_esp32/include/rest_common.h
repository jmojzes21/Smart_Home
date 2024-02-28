
#pragma once

#include <ESPAsyncWebServer.h>
#include <ArduinoJson.h>
#include <AsyncJson.h>

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
