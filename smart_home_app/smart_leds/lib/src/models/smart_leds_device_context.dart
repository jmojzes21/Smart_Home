import 'package:smart_home_core/device.dart';

import '../logic/device/device.dart';
import 'patterns/properties.dart';
import 'smart_leds_device.dart';

class SmartLedsDeviceContext extends DeviceContext<SmartLedsDevice> {
  late final DeviceClient deviceClient;
  final patternProperties = PatternProperties();

  SmartLedsDeviceContext(super.device) {
    deviceClient = DeviceClient(ipAddress: device.ipAddress!);
  }
}
