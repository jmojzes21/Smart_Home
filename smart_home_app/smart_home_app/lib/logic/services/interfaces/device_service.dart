import 'package:smart_home_core/device.dart';

abstract class IDeviceService {
  Future<List<Device>> getDevices();
}
