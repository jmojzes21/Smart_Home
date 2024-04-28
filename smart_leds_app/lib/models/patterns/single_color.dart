import 'color_pattern.dart';
import 'pattern_property.dart';

class SingleColorPattern extends ColorPattern {
  @override
  Map<String, dynamic> toJson(PatternProperties properties) {
    return {
      'name': 'single',
      'color': properties.color.rgb,
    };
  }
}
