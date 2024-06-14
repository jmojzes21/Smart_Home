import 'package:smart_leds_app/logic/device/device.dart';
import 'package:smart_leds_app/models/patterns/patterns.dart';
import 'package:smart_leds_app/models/patterns/properties.dart';

class LedController {
  final Device _device;

  int brightness = 51;

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

  Future<void> setBrightness(int brightness) async {
    this.brightness = brightness;
    await _device.postHttp(path: '/brightness', body: {'value': brightness});
  }

  Future<void> startDla() async {
    await _device.postHttp(path: '/dla_start', body: {});
  }
}
