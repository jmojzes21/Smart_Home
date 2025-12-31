import 'package:smart_home_core/device.dart';

class GenericDevice extends Device {
  final bool isOnline;

  GenericDevice({
    required super.type,
    required super.name,
    super.domain = '',
    super.ipAddress,
    super.macAddress,
    super.isReal = true,
    this.isOnline = false,
  });

  factory GenericDevice.virtual({required String name, required DeviceType type}) {
    return GenericDevice(name: name, type: type, isOnline: true, isReal: false);
  }

  bool get isOffline => !isOnline;

  Map<String, dynamic> toJson() {
    return {'type': type.toString(), 'name': name, 'hostname': domain};
  }

  factory GenericDevice.fromJson(Map<String, dynamic> json) {
    var type = DeviceType.parse(json['type']);
    if (type == DeviceType.unknown) throw Exception('Unsupported device type ${json['type']}');
    return GenericDevice(type: type, name: json['name'], domain: json['hostname']);
  }
}
