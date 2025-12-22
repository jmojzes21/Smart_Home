import 'package:smart_home_core/device.dart';

import '../../../models/generic_device.dart';
import '../interfaces/device_service.dart';

class VirtualDeviceService extends IDeviceService {
  @override
  Future<List<GenericDevice>> getDevices() async {
    return [
      GenericDevice(
        name: 'Kvaliteta zraka',
        domain: 'air-quality-sensor._smart-home._tcp.local',
        type: DeviceType.airQuality,
      ),
      GenericDevice(name: 'Pametne LEDice', domain: 'smart-leds._smart-home._tcp.local', type: DeviceType.smartLeds),
      ...getVirtualDevices(),
    ];
  }

  List<GenericDevice> getVirtualDevices() {
    return [
      GenericDevice.virtual(name: 'Kvaliteta zraka - virtualni', type: DeviceType.airQuality),
      GenericDevice.virtual(name: 'Pametne LEDice - virtualni', type: DeviceType.smartLeds),
    ];
  }
}
