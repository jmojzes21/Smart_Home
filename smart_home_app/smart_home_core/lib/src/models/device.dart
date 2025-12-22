import 'dart:io';

import 'device_type.dart';

abstract class Device {
  final DeviceType type;
  final String name;
  final String domain;

  final InternetAddress? ipAddress;
  final String? macAddress;
  final bool isReal;

  Device({
    required this.type,
    required this.name,
    this.domain = '',
    this.ipAddress,
    this.macAddress,
    this.isReal = true,
  });
}
