import 'device.dart';

class DeviceContext {
  Device? _device;

  Device get device => _device!;
  set device(Device value) => _device = value;
}
