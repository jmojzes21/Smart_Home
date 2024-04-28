import 'color_pattern.dart';
import 'pattern_property.dart';

class RainbowPattern extends ColorPattern {
  @override
  Map<String, dynamic> toJson(PatternProperties properties) {
    return {
      'name': 'rainbow',
      'dir': properties.dir,
      'rspeed': properties.rSpeed,
    };
  }
}
