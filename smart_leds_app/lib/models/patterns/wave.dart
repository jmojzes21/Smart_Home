import 'package:flutter/material.dart';

import 'color_pattern.dart';

class WavePattern extends ColorPattern {
  Color color = Colors.purple;
  int dir = 1;
  int rspeed = 10;
  int size = 1;

  @override
  Map<String, dynamic> toJson() {
    return {
      'name': 'wave',
      'color': color.rgb,
      'dir': dir,
      'rspeed': rspeed,
      'size': size,
    };
  }
}
