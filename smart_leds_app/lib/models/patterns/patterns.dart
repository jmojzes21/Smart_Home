import 'dart:ui';

import 'package:smart_leds_app/models/patterns/properties.dart';

abstract class ColorPattern {
  Map<String, dynamic> toJson(PatternProperties properties);
}

extension ColorExtension on Color {
  int get rgb => value & 0xFFFFFF;
}

class SingleColorPattern extends ColorPattern {
  @override
  Map<String, dynamic> toJson(PatternProperties properties) {
    return {
      'name': 'single',
      'color': properties.color.rgb,
    };
  }
}

class WavePattern extends ColorPattern {
  @override
  Map<String, dynamic> toJson(PatternProperties properties) {
    return {
      'name': 'wave',
      'color': properties.color.rgb,
      'speed': properties.waveSpeed,
      'changeColors': properties.waveChangeColors,
    };
  }
}

class RainbowPattern extends ColorPattern {
  @override
  Map<String, dynamic> toJson(PatternProperties properties) {
    return {
      'name': 'rainbow',
      'speed': properties.rainbowSpeed,
    };
  }
}

class RainbowBallsPattern extends ColorPattern {
  @override
  Map<String, dynamic> toJson(PatternProperties properties) {
    return {
      'name': 'rainbow_balls',
      'speed': properties.rainbowSpeed,
    };
  }
}
