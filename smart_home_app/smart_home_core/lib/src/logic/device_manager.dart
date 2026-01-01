import '../../device.dart';

class DeviceManager {
  DeviceContext? _deviceContext;

  DeviceContext get deviceContext => _deviceContext!;
  void setDeviceContext(DeviceContext deviceContext) => _deviceContext = deviceContext;
}
