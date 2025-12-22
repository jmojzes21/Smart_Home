import 'package:smart_home_core/device.dart';

import '../../../models/generic_device.dart';
import '../interfaces/device_service.dart';

class VirtualDeviceService extends IDeviceService {
  @override
  Future<List<GenericDevice>> getDevices() async {
    return [
      GenericDevice.virtual(name: 'Kvaliteta zraka - virtualni', type: DeviceType.airQuality),
      GenericDevice.virtual(name: 'Pametne LEDice - virtualni', type: DeviceType.smartLeds),
    ];
  }
}
