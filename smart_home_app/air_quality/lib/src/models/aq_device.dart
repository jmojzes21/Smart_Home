import 'package:smart_home_core/device.dart';

class AirQualityDevice extends Device {
  AirQualityDevice({required super.name, required super.hostname, super.ipAddress})
    : super(type: DeviceType.airQuality);

  factory AirQualityDevice.fromDevice(Device device) {
    return AirQualityDevice(name: device.name, hostname: device.hostname, ipAddress: device.ipAddress);
  }
}
