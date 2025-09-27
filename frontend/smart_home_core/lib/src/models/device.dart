import 'dart:io';

enum DeviceType { airQuality, smartLeds, unknown }

class Device {
  final String name;
  final String domain;
  final DeviceType type;

  final InternetAddress? ipAddress;
  final String? macAddress;
  final bool isOnline;

  Device({
    required this.name,
    required this.domain,
    required this.type,
    this.ipAddress,
    this.macAddress,
    this.isOnline = false,
  });

  bool get isOffline => !isOnline;

  factory Device.fromJson(Map<String, dynamic> json) {
    return Device(
      name: json['name'],
      domain: json['domain'],
      type: parseDeviceType(json['type']),
      ipAddress: InternetAddress(json['ip']),
      macAddress: json['mac'],
    );
  }

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
