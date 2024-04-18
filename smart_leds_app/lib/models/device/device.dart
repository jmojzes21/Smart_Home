import 'dart:async';
import 'dart:convert';
import 'dart:io';

import 'package:crypto/crypto.dart' as crypto;
import 'package:smart_leds_app/models/device/device_info.dart';
import 'package:smart_leds_app/models/firmware.dart';
import 'package:smart_leds_app/models/wifi_network.dart';

abstract class Device {
  String name;
  InternetAddress ipAddress;

  Device({
    required this.name,
    required this.ipAddress,
  });

  Future<DeviceInfo> getDeviceInfo();

  Future<void> login(String password) async {}

  Future<List<WifiNetwork>> getWifiNetworks() async => [];
  Future<void> updateWifiNetworks(List<WifiNetwork> networks) async {}

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
