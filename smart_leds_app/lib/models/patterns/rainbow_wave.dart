import 'color_pattern.dart';

class RainbowWavePattern extends ColorPattern {
  int dir = 1;
  int rspeed = 10;
  int cspeed = 10;
  int size = 1;

  @override
  Map<String, dynamic> toJson() {
    return {
      'name': 'rainbow_wave',
      'dir': dir,
      'rspeed': rspeed,
      'cspeed': cspeed,
      'size': size,
    };
  }
}
