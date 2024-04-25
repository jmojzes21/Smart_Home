import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:smart_leds_app/models/device/device.dart';
import 'package:smart_leds_app/models/patterns/color_pattern.dart';
import 'package:smart_leds_app/models/patterns/rainbow.dart';
import 'package:smart_leds_app/models/patterns/rainbow_single.dart';
import 'package:smart_leds_app/models/patterns/rainbow_wave.dart';
import 'package:smart_leds_app/models/patterns/single_color.dart';
import 'package:smart_leds_app/models/patterns/wave.dart';

class PatternProvider extends ChangeNotifier {
  final singleColorPattern = SingleColorPattern();
  final wavePattern = WavePattern();
  final rainbowPattern = RainbowPattern();
  final rainbowSinglePattern = RainbowSinglePattern();
  final rainbowWavePattern = RainbowWavePattern();

  ColorPattern? _currentPattern;

  void showPattern(ColorPattern pattern) {
    _currentPattern = pattern;
    Device.currentDevice.showPattern(pattern);
    notifyListeners();
  }

  void clearPattern() {
    _currentPattern = null;
    Device.currentDevice.clearPattern();
    notifyListeners();
  }

  ColorPattern? get currentPattern => _currentPattern;

  static PatternProvider of(BuildContext context) {
    return context.read<PatternProvider>();
  }
}
