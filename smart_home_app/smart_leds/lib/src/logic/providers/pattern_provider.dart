import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../device/device.dart';
import '../../models/patterns/patterns.dart';
import '../../models/patterns/properties.dart';

class PatternProvider {
  var properties = PatternProperties();

  void showPattern(ColorPattern pattern) {
    Device.currentDevice.leds.showPattern(pattern, properties);
  }

  void clearPattern() {
    Device.currentDevice.leds.clearPattern();
  }

  static PatternProvider of(BuildContext context) {
    return context.read<PatternProvider>();
  }
}
