import 'dart:ui';

abstract class ColorPattern {
  Map<String, dynamic> toJson(PatternProperties properties);
}

class PatternProperties {
  Color color = Color.fromARGB(0, 0, 0, 0);

  int waveSpeed = 10;
  bool waveChangeColors = false;
}

extension ColorExtension on Color {
  int get rgb => value & 0xFFFFFF;
}

// Color patterns

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
