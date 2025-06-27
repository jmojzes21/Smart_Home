import 'dart:async';

import 'package:shtc3_sensor_app/logic/device_controller.dart';
import 'package:shtc3_sensor_app/models/sensor_data.dart';

class FakeDeviceController extends DeviceController {
  final _streamController = StreamController<SensorData>();

  FakeDeviceController(super.name);

  @override
  Future<void> connect() {
    return Future.delayed(Duration(milliseconds: 500));
  }

  @override
  Future<void> disconnect() async {
    _streamController.close();
  }

  @override
  Stream<SensorData> get sensorDataStream => _streamController.stream;
}
