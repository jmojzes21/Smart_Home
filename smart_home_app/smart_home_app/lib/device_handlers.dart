import 'package:smart_home_core/device.dart';
import 'package:smart_home_core/handler.dart';
import 'package:air_quality/air_quality.dart';
import 'package:smart_leds/smart_leds.dart';

class DeviceHandlers {
  static final DeviceHandlers _instance = DeviceHandlers._();
  static DeviceHandlers get instance => _instance;

  final List<DeviceHandler> handlers = [AirQualityDeviceHandler(), SmartLedsDeviceHandler()];

  DeviceHandlers._();

  DeviceHandler? getDeviceHandler(DeviceType type) {
    int index = handlers.indexWhere((e) => e.type == type);
    return index != -1 ? handlers[index] : null;
  }
}
