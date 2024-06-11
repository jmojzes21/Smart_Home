import 'package:smart_leds_app/logic/device/device.dart';
import 'package:smart_leds_app/models/patterns/color_patterns.dart';

class LedController {
  final Device _device;

  LedController(this._device);

  Future<void> showPattern(
    ColorPattern pattern,
    PatternProperties properties,
  ) async {
    var body = pattern.toJson(properties);
    await _device.postHttp(path: '/pattern', body: body);
  }

  Future<void> clearPattern() async {
    await _device.postHttp(path: '/clear_pattern', body: {});
  }

  Future<void> startDla() async {
    await _device.postHttp(path: '/dla_start', body: {});
  }
}
