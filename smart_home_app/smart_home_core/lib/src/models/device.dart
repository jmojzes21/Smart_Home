import 'dart:io';

import 'device_type.dart';

abstract class Device {
  DeviceType type;
  String hostname;
  String name;

  InternetAddress? ipAddress;

  Device({required this.type, required this.hostname, required this.name, this.ipAddress});
  Device.virtual({required this.type, required this.name}) : hostname = '#virtual';

  bool get isVirtual => hostname == "#virtual";
}
