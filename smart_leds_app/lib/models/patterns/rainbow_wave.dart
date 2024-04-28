import 'color_pattern.dart';
import 'pattern_property.dart';

class RainbowWavePattern extends ColorPattern {
  @override
  Map<String, dynamic> toJson(PatternProperties properties) {
    return {
      'name': 'rainbow_wave',
      'dir': properties.dir,
      'rspeed': properties.rSpeed,
      'cspeed': properties.cSpeed,
      'size': properties.size,
    };
  }
}
