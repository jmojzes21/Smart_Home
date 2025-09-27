import 'package:smart_home_core/models.dart';

abstract class IDeviceService {
  Future<List<Device>> getDevices();
}
