import '../../../models/generic_device.dart';

abstract class IDeviceService {
  Future<List<ScannedDevice>> getDevices();
  Future<List<ScannedDevice>> getDevicesFromCache();

  Future<void> saveDevicesToCache(List<ScannedDevice> devices);
  Future<void> deleteDevicesFromCache();
}
