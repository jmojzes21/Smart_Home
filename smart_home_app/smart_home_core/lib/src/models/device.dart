import 'dart:io';

import 'device_type.dart';

abstract class Device {
  final DeviceType type;
  final String name;
  final String hostname;

  final InternetAddress? ipAddress;

  Device({required this.type, required this.name, required this.hostname, this.ipAddress});
}
