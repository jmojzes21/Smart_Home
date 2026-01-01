import 'dart:async';

import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:smart_home_core/device.dart';
import '../logic/device/device.dart';
import '../models/misc/power_sensor_data.dart';
import '../models/smart_leds_device_context.dart';
import '../theme.dart';
import '../widgets/misc/navigation_drawer.dart';

class PowerSensorPage extends StatelessWidget {
  const PowerSensorPage({super.key});

  @override
  Widget build(BuildContext context) {
    return Consumer<DeviceManager>(
      builder: (context, model, child) {
        var deviceContext = model.deviceContext as SmartLedsDeviceContext;
        return _PowerSensorPageBody(deviceContext);
      },
    );
  }
}

class _PowerSensorPageBody extends StatefulWidget {
  final SmartLedsDeviceContext deviceContext;

  const _PowerSensorPageBody(this.deviceContext);
  @override
  State<_PowerSensorPageBody> createState() => _PowerSensorPageState();
}

class _PowerSensorPageState extends State<_PowerSensorPageBody> {
  late DeviceClient deviceClient;

  var powerSensorData = PowerSensorData();
  Timer? refreshTimer;

  @override
  void initState() {
    super.initState();
    refresh();
  }

  void refresh() async {
    deviceClient = widget.deviceContext.deviceClient;
    var data = await deviceClient.powerSensor.getData();

    if (data.isActive) {
      refreshTimer ??= Timer.periodic(const Duration(seconds: 2), (timer) => refresh());
    } else {
      refreshTimer?.cancel();
      refreshTimer = null;
    }

    setState(() {
      powerSensorData = data;
    });
  }

  void changePowerSensorState(bool active) async {
    await deviceClient.powerSensor.setState(active);
    refresh();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Potrošnja energije')),
      drawer: const AppNavigationDrawer(),
      body: buildBody(context),
    );
  }

  Widget buildBody(BuildContext context) {
    List<Widget> content;

    if (powerSensorData.isActive) {
      content = [
        ListView(
          shrinkWrap: true,
          children: [
            buildDataTile(
              icon: Icons.power_outlined,
              title: 'Jačina struje',
              value: powerSensorData.currentString,
              minValue: powerSensorData.minCurrentString,
              maxValue: powerSensorData.maxCurrentString,
              progressValue: powerSensorData.current,
              progressMaxValue: 500,
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
          ],
        ),
        const SizedBox(height: 20),
        FilledButton(onPressed: () => changePowerSensorState(false), child: const Text('Isključi senzor')),
      ];
    } else {
      content = [
        const SizedBox(
          width: 300,
          height: 200,
          child: Center(
            child: Text(
              'Senzor potrošnje energije je isključen.',
              textAlign: TextAlign.center,
              style: MyTheme.titleLarge,
            ),
          ),
        ),
        const SizedBox(height: 40),
        FilledButton(onPressed: () => changePowerSensorState(true), child: const Text('Uključi senzor')),
      ];
    }

    return Center(
      child: Card(
        child: SizedBox(
          width: 400,
          child: Padding(
            padding: const EdgeInsets.all(20),
            child: Column(mainAxisSize: MainAxisSize.min, children: content),
          ),
        ),
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
          const SizedBox(height: 5),
          LinearProgressIndicator(value: progress),
          const SizedBox(height: 5),
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
