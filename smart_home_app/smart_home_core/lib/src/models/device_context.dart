import '../../device.dart';

abstract class DeviceContext<T extends Device> {
  final T device;

  DeviceContext(this.device);
}
