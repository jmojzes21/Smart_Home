import 'dart:io';

import 'package:smart_leds_app/models/device_info.dart';
import 'package:smart_leds_app/models/firmware.dart';

abstract class Device {
  String name;
  InternetAddress ipAddress;

  Device({
    required this.name,
    required this.ipAddress,
  });

  Future<DeviceInfo> getDeviceInfo();

  bool get isLoggedIn => false;
  Future<void> login(String password) async {}

  Future<void> updateFirmware(Firmware firmware);

  static Device? _currentDevice;

  static set currentDevice(Device? device) => _currentDevice = device;
  static Device get currentDevice => _currentDevice!;
}
