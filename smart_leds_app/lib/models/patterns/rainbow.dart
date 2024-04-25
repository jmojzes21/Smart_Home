import 'color_pattern.dart';

class RainbowPattern extends ColorPattern {
  int dir = 1;
  int rspeed = 10;

  @override
  Map<String, dynamic> toJson() {
    return {
      'name': 'rainbow',
      'dir': dir,
      'rspeed': rspeed,
    };
  }
}
