import 'package:smart_home_core/device.dart' as core;

import '../logic/device/device.dart';
import '../logic/providers/pattern_provider.dart';

class SmartLedsDevice extends core.Device {
  SmartLedsDevice({required super.name, super.domain, super.ipAddress, super.macAddress, super.isReal})
    : super(type: core.DeviceType.smartLeds) {
    Device.currentDevice = Device(name: name, ipAddress: ipAddress!);
    PatternProvider.instance = PatternProvider();
  }

  factory SmartLedsDevice.fromDevice(core.Device device) {
    return SmartLedsDevice(
      name: device.name,
      domain: device.domain,
      ipAddress: device.ipAddress,
      macAddress: device.macAddress,
      isReal: device.isReal,
    );
  }
}
