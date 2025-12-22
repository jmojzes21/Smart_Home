import '../../../models/generic_device.dart';

abstract class IDeviceService {
  Future<List<GenericDevice>> getDevices();
}
