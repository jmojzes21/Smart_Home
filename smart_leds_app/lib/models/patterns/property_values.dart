import 'package:flutter/material.dart';

class PatternPropertyValues {
  static const List<Color> basicColors = Colors.primaries;

  static const List<({int value, String label})> waveSpeedValues = [
    (value: 15, label: 'Sporo'),
    (value: 10, label: 'Umjereno'),
    (value: 5, label: 'Brzo'),
  ];

  static const List<({int value, String label})> rainbowSpeedValues = [
    (value: 80, label: 'Sporo'),
    (value: 40, label: 'Umjereno'),
    (value: 20, label: 'Brzo'),
  ];
}
