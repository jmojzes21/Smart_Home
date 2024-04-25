import 'color_pattern.dart';

class RainbowSinglePattern extends ColorPattern {
  int cspeed = 10;

  @override
  Map<String, dynamic> toJson() {
    return {
      'name': 'rainbow_single',
      'cspeed': cspeed,
    };
  }
}
