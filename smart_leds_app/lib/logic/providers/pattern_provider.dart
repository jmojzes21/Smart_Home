import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:smart_leds_app/logic/device/device.dart';
import 'package:smart_leds_app/models/patterns/color_patterns.dart';

class PatternProvider {
  var properties = PatternProperties();

  ColorPattern? _currentPattern;

  void showPattern(ColorPattern pattern) {
    _currentPattern = pattern;
    Device.currentDevice.leds.showPattern(pattern, properties);
  }

  void updatePattern() {
    if (_currentPattern != null) {
      Device.currentDevice.leds.showPattern(_currentPattern!, properties);
    }
  }

  void clearPattern() {
    _currentPattern = null;
    Device.currentDevice.leds.clearPattern();
  }

  static PatternProvider of(BuildContext context) {
    return context.read<PatternProvider>();
  }
}
