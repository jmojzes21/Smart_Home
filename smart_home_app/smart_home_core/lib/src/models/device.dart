import 'dart:io';

import 'device_type.dart';

abstract class Device {
  DeviceType type;
  String name;
  String hostname;

  InternetAddress? ipAddress;

  Device({required this.type, required this.name, required this.hostname, this.ipAddress});
}
