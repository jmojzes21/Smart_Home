import 'dart:async';
import 'dart:convert';
import 'dart:io';

import 'package:crypto/crypto.dart' as crypto;
import 'package:smart_leds_app/models/misc/firmware.dart';
import 'package:smart_leds_app/models/patterns/color_pattern.dart';
import 'package:smart_leds_app/models/misc/power_sensor_data.dart';
import 'package:smart_leds_app/models/misc/wifi_network.dart';

abstract class Device {
  String name = '';
  String type = '';
  String firmwareVersion = '';

  InternetAddress ipAddress;
  String macAddress = '';

  Device({required this.ipAddress});

  Future<void> getDeviceInfo() async {}

  Future<void> login(String password) async {}

  Future<void> showPattern(ColorPattern pattern) async {}
  Future<void> clearPattern() async {}

  Future<List<WifiNetwork>> getWifiNetworks() async => [];
  Future<void> updateWifiNetworks(List<WifiNetwork> networks) async {}

  Future<void> setPowerSensorState(bool active) async {}
  Future<PowerSensorData> getPowerSensorData() => throw UnimplementedError();

  Future<void> restart() async {}
  Future<void> changePassword(String oldPassword, String newPassword) async {}
  Future<void> updateFirmware(Firmware firmware);

  String hashPassword(String password) {
    var data = utf8.encode(password);
    var digest = crypto.sha256.convert(data);
    var base64 = base64Encode(digest.bytes);
    return base64;
  }

  static Device? _currentDevice;

  static set currentDevice(Device? device) => _currentDevice = device;
  static Device get currentDevice => _currentDevice!;
}
