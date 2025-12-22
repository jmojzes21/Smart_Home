import 'dart:io';

enum DeviceType { airQuality, smartLeds, unknown }

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

  static DeviceType parseDeviceType(String type) {
    switch (type) {
      case 'air_quality':
        return DeviceType.airQuality;
      case 'smart_leds':
        return DeviceType.smartLeds;
      default:
        return DeviceType.unknown;
    }
  }
}
