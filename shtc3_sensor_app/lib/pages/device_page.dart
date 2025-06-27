import 'dart:async';

import 'package:flutter/material.dart';
import 'package:shtc3_sensor_app/logic/device_controller.dart';
import 'package:shtc3_sensor_app/models/sensor_data.dart';

class DevicePage extends StatefulWidget {
  final DeviceController deviceController;

  const DevicePage(this.deviceController, {super.key});

  @override
  State<DevicePage> createState() => _DevicePageState();
}

class _DevicePageState extends State<DevicePage> {
  late DeviceController deviceController;

  StreamSubscription<SensorData>? sensorDataSubscription;
  SensorData sensorData = SensorData(temperature: 0, humidity: 0);

  @override
  void initState() {
    super.initState();
    deviceController = widget.deviceController;
    sensorDataSubscription = deviceController.sensorDataStream.listen(onSensorData);
  }

  void onSensorData(SensorData sensorData) {
    setState(() {
      this.sensorData = sensorData;
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: Text('SHTC3 senzor temperature')),
      body: Padding(
        padding: EdgeInsets.all(40),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text('Temperatura: ${sensorData.temperature.toStringAsFixed(2)} °C'),
            Text('Vlažnost: ${sensorData.humidity.round()} %'),
          ],
        ),
      ),
    );
  }

  @override
  void dispose() {
    sensorDataSubscription?.cancel();
    deviceController.disconnect();
    super.dispose();
  }
}
