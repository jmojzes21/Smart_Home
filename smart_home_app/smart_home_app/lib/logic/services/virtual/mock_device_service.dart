import 'package:smart_home_core/device.dart';

import '../interfaces/device_service.dart';

class VirtualDeviceService extends IDeviceService {
  @override
  Future<List<Device>> getDevices() async {
    return [
      Device(name: 'Kvaliteta zraka', domain: 'air-quality-sensor._smart-home._tcp.local', type: DeviceType.airQuality),
      Device(name: 'Pametne LEDice', domain: 'smart-leds._smart-home._tcp.local', type: DeviceType.smartLeds),
      ...getVirtualDevices(),
    ];
  }

  List<Device> getVirtualDevices() {
    return [
      Device.virtual(name: 'Kvaliteta zraka - virtualni', type: DeviceType.airQuality),
      Device.virtual(name: 'Pametne LEDice - virtualni', type: DeviceType.smartLeds),
    ];
  }
}
