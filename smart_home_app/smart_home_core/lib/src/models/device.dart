import 'dart:io';

import 'device_type.dart';

abstract class Device {
  DeviceType type;
  String hostname;
  String uuid;

  String name;

  InternetAddress? ipAddress;

  Device({required this.type, required this.hostname, required this.uuid, required this.name, this.ipAddress});
  Device.virtual({required this.type, required this.name}) : hostname = '#virtual', uuid = '';

  bool get isVirtual => hostname == "#virtual";
}
