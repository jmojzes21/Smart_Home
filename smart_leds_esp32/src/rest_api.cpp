
#include <AsyncJson.h>

#include "rest_api.h"
#include "power_sensor.h"
#include "settings.h"
#include "log.h"

extern AsyncWebServer httpServer;
extern Device device;
extern LedManager ledManager;
extern PowerSensor powerSensor;

void DeviceRestApi::setup() {
    _initLedApi();
    _initDeviceApi();
    _initWifiApi();
    _initPowerSensorApi();
    _initMiscApi();
}

bool DeviceRestApi::checkAuthentication(AsyncWebServerRequest* request) {
    std::string auth = request->header("Authorization").c_str();
    return auth == device.password;
}

bool DeviceRestApi::authenticate(AsyncWebServerRequest* request) {
    
    bool result = checkAuthentication(request);
    
    if(result == false) {
        respondCode(request, 401);
        return false;
    }

    return true;
}

void DeviceRestApi::_initLedApi() {

    // POST /pattern

    auto postPattern = new AsyncCallbackJsonWebHandler("/pattern", nullptr);
    postPattern->setMethod(HTTP_POST);
    postPattern->onRequest([&](AsyncWebServerRequest* request, JsonVariant& jsonv) {
        
        if(!authenticate(request)) return;

        JsonObject json = jsonv.as<JsonObject>();
        
        bool result = ledManager.updatePattern(json);
        respondCode(request, result ? 201 : 400);

    });
    httpServer.addHandler(postPattern);

    // POST /brightness

    auto postBrightness = new AsyncCallbackJsonWebHandler("/brightness", nullptr);
    postBrightness->setMethod(HTTP_POST);
    postBrightness->onRequest([&](AsyncWebServerRequest* request, JsonVariant& jsonv) {
        
        if(!authenticate(request)) return;

        JsonObject json = jsonv.as<JsonObject>();    
        int value = json["value"];

        if(value < 0 || value > 255) {
            respondCode(request, 400);
            return;
        }

        ledManager.setBrightness(value);
        respondCode(request, 201);

    });
    httpServer.addHandler(postBrightness);

}

void DeviceRestApi::_initDeviceApi() {

    // GET /device

    httpServer.on("/device", HTTP_GET, [&](AsyncWebServerRequest* request) {

        JsonDocument doc;
        doc["name"] = device.name;
        doc["version"] = device.version;
        doc["type"] = device.deviceType;

        doc["ip"] = WiFi.localIP().toString();
        doc["mac"] = WiFi.macAddress();
        doc["ssid"] = WiFi.SSID();

        respondJson(request, 200, doc);

    });

    // POST /login

    httpServer.on("/login", HTTP_POST, [&](AsyncWebServerRequest* request) {
        bool result = checkAuthentication(request);
        respondCode(request, result ? 201 : 400);
    });

    // POST /restart

    httpServer.on("/restart", HTTP_POST, [&](AsyncWebServerRequest* request) {

        if(!authenticate(request)) return;

        device.restart(2000);
        respondCode(request, 201);
    });

}

void DeviceRestApi::_initWifiApi() {

    // GET /wifi_networks
    // POST /wifi_networks

}

void DeviceRestApi::_initPowerSensorApi() {

    // GET /power_sensor

    httpServer.on("/power_sensor", HTTP_GET, [&](AsyncWebServerRequest* request) {

        if(!authenticate(request)) return;

        PowerSensorData data;
        powerSensor.getData(&data);

        JsonDocument doc;

        doc["current"] = data.current;
        doc["minCurrent"] = data.minCurrent;
        doc["maxCurrent"] = data.maxCurrent;

        doc["voltage"] = data.voltage;
        doc["minVoltage"] = data.minVoltage;
        doc["maxVoltage"] = data.maxVoltage;

        respondJson(request, 200, doc);

    });

    // POST /power_sensor

    auto postPowerSensor = new AsyncCallbackJsonWebHandler("/power_sensor", nullptr);
    postPowerSensor->setMethod(HTTP_POST);
    postPowerSensor->onRequest([&](AsyncWebServerRequest* request, JsonVariant& jsonv) {
        
        if(!authenticate(request)) return;

        JsonObject json = jsonv.as<JsonObject>();    
        bool active = json["active"];

        powerSensor.setActive(active);
        respondCode(request, 201);

    });
    httpServer.addHandler(postPowerSensor);

}

void DeviceRestApi::_initMiscApi() {

    // POST /dla

    httpServer.on("/dla", HTTP_POST, [&](AsyncWebServerRequest* request) {

        if(!authenticate(request)) return;

        bool result = ledManager.enableDLA();
        respondCode(request, result ? 201 : 400);
    });

    // POST /factory_reset

    httpServer.on("/factory_reset", HTTP_POST, [&](AsyncWebServerRequest* request) {

        Settings settings;
        settings.reset();

        device.restart(2000);
        respondCode(request, 201);
    });


    // GET /logs

    httpServer.on("/logs", HTTP_GET, [&](AsyncWebServerRequest* request) {
        std::string logs = qlog_get_logs();
        request->send(200, "text/plain", logs.c_str());
    });

    // DELETE /logs

    httpServer.on("/logs", HTTP_DELETE, [&](AsyncWebServerRequest* request) {
        qlog_clear();
        request->send(201);
    });

}

void DeviceRestApi::respondJson(AsyncWebServerRequest* request, int code, JsonDocument& doc) {
    
    AsyncResponseStream* response = request->beginResponseStream("application/json");
    response->setCode(code);

    serializeJson(doc, *response);
    request->send(response);
}

void DeviceRestApi::respondMessage(AsyncWebServerRequest* request, int code, const char* message) {
    
    JsonDocument doc;
    doc["msg"] = message;

    respondJson(request, code, doc);
}

void DeviceRestApi::respondCode(AsyncWebServerRequest* request, int code) {
    request->send(code);
}
