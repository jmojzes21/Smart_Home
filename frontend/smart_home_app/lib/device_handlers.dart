import 'package:air_quality/air_quality.dart';
import 'package:smart_home_core/core.dart';
import 'package:smart_home_core/models.dart';
import 'package:smart_leds/smart_leds.dart';

class DeviceHandlers {
  final List<DeviceHandler> handlers = [AirQualityDeviceHandler(), SmartLedsDeviceHandler()];

  DeviceHandler? getDeviceHandler(DeviceType type) {
    int index = handlers.indexWhere((e) => e.type == type);
    return index != -1 ? handlers[index] : null;
  }
}
