import 'dart:ui';

import 'pattern_property.dart';

abstract class ColorPattern {
  Map<String, dynamic> toJson(PatternProperties properties);
}

extension ColorExtension on Color {
  int get rgb => value & 0xFFFFFF;
}
