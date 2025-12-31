import '../../../models/generic_device.dart';

abstract class IDeviceService {
  Future<List<GenericDevice>> getDevices();
  Future<List<GenericDevice>> getDevicesFromCache();

  Future<void> saveDevicesToCache(List<GenericDevice> devices);
}
