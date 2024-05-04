import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:smart_leds_app/logic/device/device.dart';
import 'package:smart_leds_app/models/patterns/color_pattern.dart';
import 'package:smart_leds_app/models/patterns/pattern_property.dart';
import 'package:smart_leds_app/models/patterns/rainbow.dart';
import 'package:smart_leds_app/models/patterns/rainbow_single.dart';
import 'package:smart_leds_app/models/patterns/rainbow_wave.dart';
import 'package:smart_leds_app/models/patterns/single_color.dart';
import 'package:smart_leds_app/models/patterns/wave.dart';

class PatternProvider {
  var properties = PatternProperties();

  var singleColorPattern = SingleColorPattern();
  var wavePattern = WavePattern();
  var rainbowPattern = RainbowPattern();
  var rainbowSinglePattern = RainbowSinglePattern();
  var rainbowWavePattern = RainbowWavePattern();

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
