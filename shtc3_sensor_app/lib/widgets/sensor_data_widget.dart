import 'package:flutter/material.dart';
import 'package:shtc3_sensor_app/models/sensor_data.dart';

class SensorDataWidget extends StatelessWidget {
  final SensorData sensorData;

  const SensorDataWidget(this.sensorData, {super.key});

  @override
  Widget build(BuildContext context) {
    return CustomPaint(willChange: true, painter: _SensorDataPainter(sensorData));
  }
}

class _SensorDataPainter extends CustomPainter {
  final SensorData sensorData;

  _SensorDataPainter(this.sensorData);

  @override
  void paint(Canvas canvas, Size size) {}

  @override
  bool shouldRepaint(covariant CustomPainter oldDelegate) {
    return false;
  }
}
