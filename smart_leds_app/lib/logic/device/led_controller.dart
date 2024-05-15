import 'package:smart_leds_app/logic/device/device.dart';
import 'package:smart_leds_app/models/patterns/color_pattern.dart';
import 'package:smart_leds_app/models/patterns/pattern_property.dart';

class LedController {
  // ignore: unused_field
  final Device _device;

  LedController(this._device);

  Future<void> showPattern(
    ColorPattern pattern,
    PatternProperties properties,
  ) async {}

  Future<void> clearPattern() async {}

  Future<void> startDla() async {
    await _device.postHttp(path: '/dla_start', body: {});
  }
}
