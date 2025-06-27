import 'dart:async';

import 'package:shtc3_sensor_app/models/sensor_data.dart';

abstract class DeviceController {
  final String _name;

  DeviceController(this._name);

  Future<void> connect();
  Future<void> disconnect();

  Stream<SensorData> get sensorDataStream;
  String get name => _name;
}
