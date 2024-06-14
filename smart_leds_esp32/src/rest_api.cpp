
#include <AsyncJson.h>

#include "rest_api.h"
#include "power_sensor.h"
#include "settings.h"

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

    // POST /clear_pattern

    httpServer.on("/clear_pattern", HTTP_POST, [&](AsyncWebServerRequest* request) {

        if(!authenticate(request)) return;

        ledManager.clearPattern();
        respondCode(request, 201);
    });

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
        doc["rssi"] = (int)WiFi.RSSI();

        respondJson(request, 200, doc);

    });

    // POST /login

    httpServer.on("/login", HTTP_POST, [&](AsyncWebServerRequest* request) {
        bool result = checkAuthentication(request);

        if(result) {
            respondCode(request, 201);
        }else{
            respondMessage(request, 400, "Netočna lozinka.");
        }
    });

}

void DeviceRestApi::_initWifiApi() {

    // GET /wifi_networks

    httpServer.on("/wifi_networks", HTTP_GET, [&](AsyncWebServerRequest* request) {

        if(!authenticate(request)) return;

        JsonDocument doc;

        Settings settings;
        settings.load();

        JsonArray networks = doc["networks"].to<JsonArray>();
        for(int i = 0; i < settings.wifiNetworks.size(); i++) {

            WifiNetwork& net = settings.wifiNetworks[i];
            JsonObject network = networks[i].to<JsonObject>();

            network["ssid"] = net.ssid;
            network["pass"] = net.password;
        }

        respondJson(request, 200, doc);

    });

    // POST /wifi_networks

    auto postWifiNetworks = new AsyncCallbackJsonWebHandler("/wifi_networks", nullptr);
    postWifiNetworks->setMethod(HTTP_POST);
    postWifiNetworks->onRequest([&](AsyncWebServerRequest* request, JsonVariant& jsonv) {
        
        if(!authenticate(request)) return;

        JsonObject json = jsonv.as<JsonObject>();    
        
        Settings settings;
        settings.load();

        settings.wifiNetworks.clear();

        JsonArray networks = json["networks"];
        for(int i = 0; i < networks.size(); i++) {
            JsonObject net = networks[i];

            std::string ssid = net["ssid"];
            std::string pass = net["pass"];

            settings.wifiNetworks.emplace_back(ssid, pass);
        }

        settings.save();

        respondCode(request, 201);

    });
    httpServer.addHandler(postWifiNetworks);

}

void DeviceRestApi::_initPowerSensorApi() {

    // GET /power_sensor

    httpServer.on("/power_sensor", HTTP_GET, [&](AsyncWebServerRequest* request) {

        if(!authenticate(request)) return;

        JsonDocument doc;

        bool active = powerSensor.isActive();
        doc["active"] = active;

        if(active) {

            PowerSensorData data;
            powerSensor.getData(&data);

            doc["current"] = data.current;
            doc["minCurrent"] = data.minCurrent;
            doc["maxCurrent"] = data.maxCurrent;

            doc["voltage"] = data.voltage;
            doc["minVoltage"] = data.minVoltage;
            doc["maxVoltage"] = data.maxVoltage;
        }

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

    // POST /restart

    httpServer.on("/restart", HTTP_POST, [&](AsyncWebServerRequest* request) {

        if(!authenticate(request)) return;

        device.restart(2000);
        respondCode(request, 201);
    });

    // POST /auth

    auto postAuth = new AsyncCallbackJsonWebHandler("/auth", nullptr);
    postAuth->setMethod(HTTP_POST);
    postAuth->onRequest([&](AsyncWebServerRequest* request, JsonVariant& jsonv) {
        
        if(!authenticate(request)) return;

        JsonObject json = jsonv.as<JsonObject>();    
        std::string newPassword = json["pass"];

        device.password = newPassword;

        Settings settings;
        settings.load();
        settings.devicePassword = newPassword;
        settings.save();

        respondCode(request, 201);

    });
    httpServer.addHandler(postAuth);

    // POST /dla_start

    httpServer.on("/dla_start", HTTP_POST, [&](AsyncWebServerRequest* request) {

        if(!authenticate(request)) return;

        ledManager.enableDLA();
        respondCode(request, 201);
    });

    // POST /wipe_data

    httpServer.on("/wipe_data", HTTP_POST, [&](AsyncWebServerRequest* request) {

        Settings settings;
        settings.reset();

        device.restart(2000);
        respondCode(request, 201);
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
