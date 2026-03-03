import 'package:smart_home_core/device.dart';

class AqDevice extends Device {
  AqDevice({required super.name, required super.hostname, required super.uuid, super.ipAddress})
    : super(type: DeviceType.airQuality);

  factory AqDevice.fromDevice(Device device) {
    return AqDevice(name: device.name, hostname: device.hostname, uuid: device.uuid, ipAddress: device.ipAddress);
  }
}
