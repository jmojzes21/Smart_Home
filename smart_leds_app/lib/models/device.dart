import 'dart:io';

import 'package:smart_leds_app/models/device_info.dart';

abstract class Device {
  String name;
  InternetAddress ipAddress;

  Device({
    required this.name,
    required this.ipAddress,
  });

  Future<DeviceInfo> getDeviceInfo();

  static Device? _currentDevice;

  static set currentDevice(Device? device) => _currentDevice = device;
  static Device get currentDevice => _currentDevice!;
}
