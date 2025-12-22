import 'package:smart_home_core/device.dart';

class AirQualityDevice extends Device {
  AirQualityDevice({required super.name, super.domain, super.ipAddress, super.macAddress, super.isOnline, super.isReal})
    : super(type: DeviceType.airQuality);

  factory AirQualityDevice.fromDevice(Device device) {
    return AirQualityDevice(
      name: device.name,
      domain: device.domain,
      ipAddress: device.ipAddress,
      macAddress: device.macAddress,
      isOnline: device.isOnline,
      isReal: device.isReal,
    );
  }
}
