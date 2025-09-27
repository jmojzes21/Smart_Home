import 'package:smart_home_app/logic/services/virtual/device_service.dart';
import 'package:smart_home_core/models.dart';

class MockDeviceService extends IDeviceService {
  @override
  Future<List<Device>> getDevices() async {
    return [
      Device(name: 'Kvaliteta zraka', domain: 'air-quality-sensor._smart-home._tcp.local', type: DeviceType.airQuality),
      Device(name: 'Pametne LEDice', domain: 'smart-leds._smart-home._tcp.local', type: DeviceType.smartLeds),
    ];
  }
}
