import 'device.dart';
import '../../models/patterns/patterns.dart';
import '../../models/patterns/properties.dart';

class LedController {
  final DeviceClient _device;

  int brightness = 51;

  LedController(this._device);

  Future<void> showPattern(ColorPattern pattern, PatternProperties properties) async {
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
