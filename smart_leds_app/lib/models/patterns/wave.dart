import 'color_pattern.dart';
import 'pattern_property.dart';

class WavePattern extends ColorPattern {
  @override
  Map<String, dynamic> toJson(PatternProperties properties) {
    return {
      'name': 'wave',
      'color': properties.color.rgb,
      'dir': properties.dir,
      'rspeed': properties.rSpeed,
      'size': properties.size,
    };
  }
}
