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
}
