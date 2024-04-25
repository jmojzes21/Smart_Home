import 'dart:ui';

abstract class ColorPattern {
  Map<String, dynamic> toJson();
}

extension ColorExtension on Color {
  int get rgb => value & 0xFFFFFF;
}
