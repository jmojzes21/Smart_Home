import 'package:smart_leds_app/models/device_info.dart';

abstract class Device {
  Future<DeviceInfo> getDeviceInfo();

  static Device? _currentDevice;

  static void set currentDevice(Device? device) => _currentDevice = device;
  static Device get currentDevice => _currentDevice!;
}
