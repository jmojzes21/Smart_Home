import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:smart_leds_app/logic/device/device.dart';
import 'package:smart_leds_app/models/patterns/patterns.dart';
import 'package:smart_leds_app/models/patterns/properties.dart';

class PatternProvider {
  var properties = PatternProperties();

  void showPattern(ColorPattern pattern) {
    Device.currentDevice.leds.showPattern(pattern!, properties);
  }

  void clearPattern() {
    Device.currentDevice.leds.clearPattern();
  }

  static PatternProvider of(BuildContext context) {
    return context.read<PatternProvider>();
  }
}
