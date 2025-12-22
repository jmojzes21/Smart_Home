import '../device/device.dart';
import '../../models/patterns/patterns.dart';
import '../../models/patterns/properties.dart';

class PatternProvider {
  static PatternProvider? instance;

  var properties = PatternProperties();

  void showPattern(ColorPattern pattern) {
    Device.currentDevice.leds.showPattern(pattern, properties);
  }

  void clearPattern() {
    Device.currentDevice.leds.clearPattern();
  }
}
