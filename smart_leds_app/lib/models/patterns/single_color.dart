import 'package:flutter/material.dart';

import 'color_pattern.dart';

class SingleColorPattern extends ColorPattern {
  Color color = Colors.purple;

  @override
  Map<String, dynamic> toJson() {
    return {
      'name': 'single',
      'color': color.rgb,
    };
  }
}
