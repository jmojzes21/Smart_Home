import 'dart:async';

import 'package:flutter/material.dart';
import 'package:smart_leds_app/logic/device/device.dart';
import 'package:smart_leds_app/models/misc/power_sensor_data.dart';
import 'package:smart_leds_app/theme.dart';
import 'package:smart_leds_app/widgets/misc/navigation_drawer.dart';

class PowerSensorPage extends StatefulWidget {
  const PowerSensorPage({super.key});
  @override
  State<PowerSensorPage> createState() => _PowerSensorPageState();
}

class _PowerSensorPageState extends State<PowerSensorPage> {
  var powerSensorData = PowerSensorData();
  Timer? refreshTimer;

  @override
  void initState() {
    super.initState();
    refresh();
  }

  void refresh() async {
    var device = Device.currentDevice;
    var data = await device.powerSensor.getData();

    if (data.isActive) {
      refreshTimer ??=
          Timer.periodic(Duration(seconds: 2), (timer) => refresh());
    } else {
      refreshTimer?.cancel();
      refreshTimer = null;
    }

    setState(() {
      powerSensorData = data;
    });
  }

  void changePowerSensorState(bool active) async {
    var device = Device.currentDevice;
    await device.powerSensor.setState(active);
    refresh();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Potrošnja energije'),
      ),
      drawer: AppNavigationDrawer(),
      body: buildBody(context),
    );
  }

  Widget buildBody(BuildContext context) {
    var content = <Widget>[];

    if (powerSensorData.isActive) {
      content.addAll([
        buildDataTile(
          icon: Icons.power_outlined,
          title: 'Jačina strije',
          value: powerSensorData.currentString,
          minValue: powerSensorData.minCurrentString,
          maxValue: powerSensorData.maxCurrentString,
          progressValue: powerSensorData.current,
          progressMaxValue: 3000,
        ),
        buildDataTile(
          icon: Icons.battery_0_bar_outlined,
          title: 'Napon',
          value: powerSensorData.voltageString,
          minValue: powerSensorData.minVoltageString,
          maxValue: powerSensorData.maxVoltageString,
          progressValue: powerSensorData.voltage,
          progressMaxValue: 5,
        ),
        SizedBox(height: 20),
      ]);
    }

    content.add(
      SwitchListTile(
        value: powerSensorData.isActive,
        controlAffinity: ListTileControlAffinity.leading,
        title: Text(powerSensorData.isActive
            ? 'Senzor potrošnje energije je aktivan'
            : 'Senzor potrošnje energije nije aktivan'),
        onChanged: (value) => changePowerSensorState(value),
      ),
    );

    return Center(
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          SizedBox(
            width: 400,
            child: ListView(
              shrinkWrap: true,
              children: content,
            ),
          ),
        ],
      ),
    );
  }

  Widget buildDataTile({
    required IconData icon,
    required String title,
    required String value,
    required String minValue,
    required String maxValue,
    required double progressValue,
    required double progressMaxValue,
  }) {
    double progress = progressValue / progressMaxValue;
    if (progress > 1) progress = 1;

    return ListTile(
      leading: Icon(icon, size: 40),
      title: Text(title, style: MyTheme.titleMedium),
      titleAlignment: ListTileTitleAlignment.top,
      subtitle: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        mainAxisSize: MainAxisSize.min,
        children: [
          Text(value),
          SizedBox(height: 5),
          LinearProgressIndicator(value: progress),
          SizedBox(height: 5),
          Text(minValue),
          Text(maxValue),
        ],
      ),
    );
  }

  @override
  void dispose() {
    refreshTimer?.cancel();
    super.dispose();
  }
}
