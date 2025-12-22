import 'dart:io';

enum DeviceType { airQuality, smartLeds, unknown }

class Device {
  final DeviceType type;
  final String name;
  final String domain;

  final InternetAddress? ipAddress;
  final String? macAddress;
  final bool isOnline;
  final bool isReal;

  Device({
    required this.type,
    required this.name,
    this.domain = '',
    this.ipAddress,
    this.macAddress,
    this.isOnline = false,
    this.isReal = true,
  });

  factory Device.virtual({required String name, required DeviceType type}) {
    return Device(name: name, type: type, isOnline: true, isReal: false);
  }

  bool get isOffline => !isOnline;

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
