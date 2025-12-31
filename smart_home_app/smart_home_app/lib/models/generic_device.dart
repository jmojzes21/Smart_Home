import 'package:smart_home_core/device.dart';

class GenericDevice extends Device {
  bool isOnline;

  GenericDevice({
    required super.type,
    required super.name,
    required super.hostname,
    super.ipAddress,
    this.isOnline = false,
  });

  factory GenericDevice.virtual({required String name, required DeviceType type}) {
    return GenericDevice(type: type, name: name, hostname: '#virtual', isOnline: true);
  }

  bool get isOffline => !isOnline;

  Map<String, dynamic> toJson() {
    return {'type': type.toString(), 'name': name, 'hostname': hostname};
  }

  factory GenericDevice.fromJson(Map<String, dynamic> json) {
    var type = DeviceType.parse(json['type']);
    if (type == DeviceType.unknown) throw Exception('Unsupported device type ${json['type']}');
    return GenericDevice(type: type, name: json['name'], hostname: json['hostname']);
  }
}
