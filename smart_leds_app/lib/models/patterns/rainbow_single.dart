import 'color_pattern.dart';
import 'pattern_property.dart';

class RainbowSinglePattern extends ColorPattern {
  @override
  Map<String, dynamic> toJson(PatternProperties properties) {
    return {
      'name': 'rainbow_single',
      'cspeed': properties.cSpeed,
    };
  }
}
