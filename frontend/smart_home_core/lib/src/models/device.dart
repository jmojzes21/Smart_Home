import 'dart:io';

enum DeviceType { airQuality, smartLeds, unknown }

class Device {
  final String name;
  final String hostname;
  final DeviceType type;

  final InternetAddress ipAddress;
  final String macAddress;

  Device({required this.name, required this.hostname, required this.type, required this.ipAddress, required this.macAddress});

  factory Device.fromJson(Map<String, dynamic> json) {
    return Device(name: json['name'], hostname: json['hostname'], type: parseDeviceType(json['type']), ipAddress: InternetAddress(json['ip']), macAddress: json['mac']);
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
