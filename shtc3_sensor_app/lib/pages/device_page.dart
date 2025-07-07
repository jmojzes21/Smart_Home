import 'dart:async';

import 'package:flutter/material.dart';
import 'package:shtc3_sensor_app/logic/device_controller.dart';
import 'package:shtc3_sensor_app/logic/exceptions.dart';
import 'package:shtc3_sensor_app/models/sensor_data.dart';
import 'package:shtc3_sensor_app/pages/device_error_page.dart';

class DevicePage extends StatefulWidget {
  const DevicePage({super.key});

  @override
  State<DevicePage> createState() => _DevicePageState();
}

class _DevicePageState extends State<DevicePage> {
  var deviceController = DeviceController();

  var isLoading = true;

  SensorData? sensorData;
  Timer? timer;

  @override
  void initState() {
    super.initState();
    init();
  }

  void init() async {
    try {
      var sensorData = await deviceController.getSensorData();

      if (!mounted) return;
      setState(() {
        this.sensorData = sensorData;
        isLoading = false;
      });

      timer = Timer.periodic(Duration(milliseconds: 2000), (timer) => getSensorData());
    } on AppException catch (e) {
      if (!mounted) return;
      Navigator.of(context).pushReplacement(MaterialPageRoute(builder: (context) => DeviceErrorPage(e.message)));
    }
  }

  Future<void> getSensorData() async {
    try {
      var sensorData = await deviceController.getSensorData();

      if (!mounted) return;
      setState(() {
        this.sensorData = sensorData;
      });
    } on AppException catch (e) {
      timer?.cancel();
      timer = null;

      if (!mounted) return;
      Navigator.of(context).pushReplacement(MaterialPageRoute(builder: (context) => DeviceErrorPage(e.message)));
    }
  }

  @override
  Widget build(BuildContext context) {
    Widget body;

    if (isLoading) {
      body = Center(child: CircularProgressIndicator());
    } else {
      body = Padding(
        padding: EdgeInsets.all(40),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text('Temperatura: ${sensorData!.temperature.toStringAsFixed(1)} °C'),
            Text('Vlaga zraka: ${sensorData!.humidity.round()} %'),
          ],
        ),
      );
    }

    return Scaffold(
      appBar: AppBar(title: Text('SHTC3 senzor temperature')),
      body: body,
    );
  }

  @override
  void dispose() {
    timer?.cancel();
    super.dispose();
  }
}
