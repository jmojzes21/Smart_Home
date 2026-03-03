import 'package:smart_home_core/device.dart';

class SmartLedsDevice extends Device {
  SmartLedsDevice({required super.name, required super.hostname, required super.uuid, super.ipAddress})
    : super(type: DeviceType.smartLeds);

  factory SmartLedsDevice.fromDevice(Device device) {
    return SmartLedsDevice(
      name: device.name,
      hostname: device.hostname,
      uuid: device.uuid,
      ipAddress: device.ipAddress,
    );
  }
}
