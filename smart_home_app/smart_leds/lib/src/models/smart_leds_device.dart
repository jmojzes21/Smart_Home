import 'package:smart_home_core/device.dart';

class SmartLedsDevice extends Device {
  SmartLedsDevice({required super.name, required super.hostname, super.ipAddress}) : super(type: DeviceType.smartLeds);

  factory SmartLedsDevice.fromDevice(Device device) {
    return SmartLedsDevice(name: device.name, hostname: device.hostname, ipAddress: device.ipAddress);
  }
}
