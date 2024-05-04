import 'dart:async';
import 'dart:convert';
import 'dart:developer';
import 'dart:io';

import 'package:crypto/crypto.dart' as crypto;
import 'package:http/http.dart' as http;
import 'package:smart_leds_app/logic/device/led_controller.dart';
import 'package:smart_leds_app/logic/device/power_sensor.dart';
import 'package:smart_leds_app/logic/device/wifi_controller.dart';
import 'package:smart_leds_app/models/exceptions.dart';
import 'package:smart_leds_app/models/misc/firmware.dart';

typedef JsonObject = Map<String, dynamic>;

class Device {
  String name = '';
  String type = '';
  String firmwareVersion = '';

  InternetAddress ipAddress;
  String macAddress = '';

  late LedController leds;
  late WifiController wifi;
  late PowerSensor powerSensor;

  String _authentication = '';

  Device({this.name = '', required this.ipAddress}) {
    leds = LedController(this);
    wifi = WifiController(this);
    powerSensor = PowerSensor(this);
  }

  Future<void> getDeviceInfo() async {
    var json = await getHttp(path: '/device');

    String name = json['name'];
    String type = json['type'];
    String firmwareVersion = json['version'];
    String macAddress = json['mac'];

    this.name = name;
    this.type = type;
    this.firmwareVersion = firmwareVersion;
    this.macAddress = macAddress;
  }

  Future<void> login(String password) async {
    _authentication = password;
    await postHttp(path: '/login', body: {});
  }

  Future<void> restart() async {
    await postHttp(path: '/restart', body: {});
  }

  Future<void> changePassword(String oldPassword, String newPassword) async {}
  Future<void> updateFirmware(Firmware firmware) async {
    Uri uri = Uri.http(ipAddress.address, 'firmware_update');
    http.Response response;
    String message;

    try {
      response = await http.post(
        uri,
        headers: {
          'Content-Type': 'application/octet-stream',
          'Device-Type': firmware.deviceType,
          'Firmware-Size': firmware.bytes.length.toString(),
          'Firmware-HMAC': firmware.hmac,
        },
        body: firmware.bytes,
      );

      message = jsonDecode(response.body)['msg'] ?? '';
    } on Exception catch (_) {
      throw FirmwareUpdateException('Povezivanje na uređaj nije uspjelo.');
    }

    if (response.statusCode != 201) {
      throw FirmwareUpdateException(message);
    }
  }

  String hashPassword(String password) {
    var data = utf8.encode(password);
    var digest = crypto.sha256.convert(data);
    var base64 = base64Encode(digest.bytes);
    return base64;
  }

  Future<JsonObject> getHttp({required String path}) async {
    Uri uri = Uri.http(ipAddress.address, path);
    log('GET $path');

    var headers = {'Authorization': _authentication};

    http.Response res;
    var st = Stopwatch()..start();

    try {
      res = await http.get(uri, headers: headers);
      st.stop();
    } on Exception catch (e) {
      log(e.toString());
      throw DeviceNotConnectedException();
    }

    log('${res.statusCode}, ${st.elapsedMilliseconds} ms');

    if (res.statusCode == 401) {
      throw DeviceAuthenticationException();
    }

    var data = res.json;

    if (res.statusCode != 200) {
      throw DeviceException(data['msg']);
    }

    return data;
  }

  Future<JsonObject> postHttp({
    required String path,
    required JsonObject body,
  }) async {
    Uri uri = Uri.http(ipAddress.address, path);
    log('POST $path');

    String json = jsonEncode(body);
    var headers = {
      'Content-Type': 'application/json',
      'Authorization': _authentication,
    };

    http.Response res;
    var st = Stopwatch()..start();

    try {
      res = await http.post(uri, headers: headers, body: json, encoding: utf8);
      st.stop();
    } on Exception catch (e) {
      log(e.toString());
      throw DeviceNotConnectedException();
    }

    log('${res.statusCode}, ${st.elapsedMilliseconds} ms');

    if (res.statusCode == 401) {
      throw DeviceAuthenticationException();
    }

    var data = res.json;

    if (res.statusCode != 201) {
      throw DeviceException(data['msg']);
    }

    return data;
  }

  static Device? _currentDevice;

  static set currentDevice(Device? device) => _currentDevice = device;
  static Device get currentDevice => _currentDevice!;
}

extension on http.Response {
  JsonObject get json {
    if (body.isEmpty) return {};
    var jsonText = Utf8Decoder().convert(bodyBytes);
    return jsonDecode(jsonText);
  }
}
