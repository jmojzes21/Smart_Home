import '../../device.dart';

class DeviceManager {
  Device? _currentDevice;

  Device get device => _currentDevice!;
  void setDevice(Device device) => _currentDevice = device;
}
