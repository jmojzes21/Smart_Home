import 'package:smart_home_core/device.dart';

enum Availability { unknown, online, offline }

class ScannedDevice extends Device {
  Availability availability;

  ScannedDevice({
    required super.type,
    required super.name,
    required super.hostname,
    super.ipAddress,
    this.availability = Availability.unknown,
  });

  factory ScannedDevice.virtual({required String name, required DeviceType type}) {
    return ScannedDevice(type: type, name: name, hostname: '#virtual', availability: Availability.online);
  }

  Map<String, dynamic> toJson() {
    return {'type': type.toString(), 'name': name, 'hostname': hostname};
  }

  factory ScannedDevice.fromJson(Map<String, dynamic> json) {
    var type = DeviceType.parse(json['type']);
    if (type == DeviceType.unknown) throw Exception('Unsupported device type ${json['type']}');
    return ScannedDevice(type: type, name: json['name'], hostname: json['hostname']);
  }
}
