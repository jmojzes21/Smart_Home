import 'dart:async';

import 'package:flutter/material.dart';
import 'package:air_quality_app/logic/device_controller.dart';
import 'package:air_quality_app/logic/exceptions.dart';
import 'package:air_quality_app/models/sensor_data.dart';
import 'package:air_quality_app/pages/device_error_page.dart';
import 'package:air_quality_app/widgets/sensor_data_widget.dart';

class DevicePage extends StatefulWidget {
  const DevicePage({super.key});

  @override
  State<DevicePage> createState() => _DevicePageState();
}

class _DevicePageState extends State<DevicePage> {
  var deviceController = DeviceController();

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
      });
    } on AppException catch (e) {
      if (!mounted) return;
      Navigator.of(context).pushReplacement(MaterialPageRoute(builder: (context) => DeviceErrorPage(e.message)));
      return;
    }

    timer = Timer.periodic(Duration(milliseconds: 2000), (timer) => getSensorData());
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

    if (sensorData != null) {
      body = SensorDataWidget(sensorData!);
    } else {
      body = Center(child: CircularProgressIndicator());
    }

    return Scaffold(
      appBar: AppBar(title: Text('Senzor temperature')),
      body: body,
    );
  }

  @override
  void dispose() {
    timer?.cancel();
    super.dispose();
  }
}
