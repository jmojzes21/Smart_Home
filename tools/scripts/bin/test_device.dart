import 'dart:convert';
import 'dart:math' as math;

import 'package:shelf/shelf.dart';
import 'package:shelf_router/shelf_router.dart';
import 'package:shelf/shelf_io.dart' as io;

var app = Router();

void main() {
  ledApi();
  deviceApi();
  wifiApi();
  powerSensorApi();
  otaUpdateApi();
  miscApi();

  io.serve(app, '127.0.0.1', 80);
  print('Server je pokrenut');
}

void ledApi() {
  app.post('/pattern', (Request req) {
    return response(201);
  });

  app.post('/brightness', (Request req) {
    return response(201);
  });
}

void deviceApi() {
  app.get('/device', (Request req) {
    return response(200, {
      'name': 'Testni uređaj',
      'version': 'v1.0.0',
      'type': 'Smart LEDs L7',
      'ip': '127.0.0.1',
      'mac': '00:00:00:00:00:00',
      'ssid': 'local_network'
    });
  });

  app.post('/login', (Request req) {
    return response(201);
  });
}

dynamic wifi = {
  'networks': [
    {'ssid': 'Earth', 'pass': 'Earth'},
    {'ssid': 'Water', 'pass': 'Water'},
    {'ssid': 'Forest', 'pass': 'Forest'},
  ]
};

void wifiApi() {
  app.get('/wifi_networks', (Request req) {
    return response(200, wifi);
  });

  app.post('/wifi_networks', (Request req) async {
    wifi = await req.json;
    return response(201);
  });
}

dynamic powerSensor = {
  'active': false,
  'current': 200,
  'minCurrent': 50,
  'maxCurrent': 1200,
  'voltage': 4.8,
  'minVoltage': 4.5,
  'maxVoltage': 5,
};

void powerSensorApi() {
  app.get('/power_sensor', (Request req) {
    return response(200, powerSensor);
  });

  app.post('/power_sensor', (Request req) async {
    var json = await req.json;
    powerSensor['active'] = json['active'];
    return response(201);
  });
}

void miscApi() {
  app.post('/restart', (Request req) {
    return response(201);
  });

  app.post('/auth', (Request req) {
    return response(201);
  });

  app.post('/dla', (Request req) {
    return response(201);
  });

  app.post('/wipe_data', (Request req) {
    return response(201);
  });
}

void otaUpdateApi() {
  app.post('/firmware_update', (Request req) async {
    await Future.delayed(Duration(seconds: 4));
    var r = math.Random();
    if (r.nextDouble() < 0.5) {
      return response(
          400, 'Nepoznata greška pri ažuriranju ugradbenog programa.');
    }
    return response(201);
  });
}

Response response(int code, [dynamic data]) {
  if (data == null) {
    data = {};
  } else if (data is String) {
    data = {'msg': data};
  }

  return Response(
    code,
    body: jsonEncode(data),
    headers: {'Content-Type': 'application/json'},
  );
}

extension on Request {
  Future<dynamic> get json async {
    return jsonDecode(await readAsString());
  }
}
