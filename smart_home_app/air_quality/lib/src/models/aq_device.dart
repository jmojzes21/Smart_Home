import 'package:smart_home_core/device.dart';

class AqDevice extends Device {
  AqDevice({required super.name, required super.hostname, super.ipAddress}) : super(type: DeviceType.airQuality);

  factory AqDevice.fromDevice(Device device) {
    return AqDevice(name: device.name, hostname: device.hostname, ipAddress: device.ipAddress);
  }
}
