import 'package:smart_leds_app/models/device_info.dart';

import 'device.dart';

class VirtualDevice extends Device {
  VirtualDevice({required super.name, required super.ipAddress});

  @override
  Future<DeviceInfo> getDeviceInfo() {
    return Future.delayed(
      Duration(milliseconds: 500),
      () {
        return DeviceInfo(
          name: 'Virtualni uređaj',
          firmwareVersion: '1.0.0',
          ipAddress: '0.0.0.0',
          macAddress: '00:00:00:00:00:00',
          wifiSSID: 'WiFi Network SSID',
          wifiRSSI: -50,
        );
      },
    );
  }
}
