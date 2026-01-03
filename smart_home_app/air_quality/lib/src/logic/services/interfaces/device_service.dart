import '../../../models/device_status.dart';

abstract class IDeviceService {
  Future<DeviceStatus> getDeviceStatus();
}
