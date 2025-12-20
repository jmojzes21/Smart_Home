import 'package:flutter/material.dart';

class PatternPropertyValues {
  static const List<Color> basicColors = [
    Color.fromARGB(255, 255, 0, 0),
    Color.fromARGB(255, 255, 94, 0),
    Color.fromARGB(255, 255, 255, 0),
    Color.fromARGB(255, 127, 255, 0),
    Color.fromARGB(255, 0, 255, 0),
    Color.fromARGB(255, 0, 191, 255),
    Color.fromARGB(255, 0, 0, 255),
    Color.fromARGB(255, 255, 0, 255),
    Color.fromARGB(255, 127, 0, 255),
    Color.fromARGB(255, 255, 0, 64),
    Color.fromARGB(255, 255, 255, 255),
  ];

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
