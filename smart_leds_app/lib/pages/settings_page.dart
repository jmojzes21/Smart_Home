import 'package:flutter/material.dart';
import 'package:smart_leds_app/models/device.dart';
import 'package:smart_leds_app/models/device_info.dart';
import 'package:smart_leds_app/widgets/navigation_drawer.dart';
import 'package:smart_leds_app/widgets/update_dialogs.dart';

class SettingsPage extends StatefulWidget {
  const SettingsPage({super.key});
  @override
  State<SettingsPage> createState() => _SettingsPageState();
}

class _SettingsPageState extends State<SettingsPage> {
  DeviceInfo? deviceInfo;

  @override
  void initState() {
    super.initState();
    getDeviceInfo();
  }

  void getDeviceInfo() async {
    var info = await Device.currentDevice.getDeviceInfo();
    setState(() {
      deviceInfo = info;
    });
  }

  void openPrepareUpdateDialog(BuildContext context) {
    showDialog(
      context: context,
      barrierDismissible: false,
      builder: (context) {
        return PrepareUpdateWidget();
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Postavke'),
      ),
      drawer: AppNavigationDrawer(),
      body: buildBody(context),
    );
  }

  Widget buildBody(BuildContext context) {
    if (deviceInfo == null) {
      return Center(
        child: SizedBox.square(
          dimension: 100,
          child: CircularProgressIndicator(),
        ),
      );
    }

    var theme = Theme.of(context).textTheme;
    var titleStyle = theme.titleMedium;
    var bodyStyle = theme.bodyMedium;
    const spacing = 10.0;

    return Padding(
      padding: const EdgeInsets.all(40),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text('Naziv', style: titleStyle),
          Text(deviceInfo!.name, style: bodyStyle),
          SizedBox(height: spacing),
          Text('Verzija', style: titleStyle),
          Text(deviceInfo!.firmwareVersion, style: bodyStyle),
          SizedBox(height: spacing),
          Text('WiFi mreža', style: titleStyle),
          Text(deviceInfo!.wifiSSID, style: bodyStyle),
          SizedBox(height: spacing),
          Text('IP adresa', style: titleStyle),
          Text(deviceInfo!.ipAddress, style: bodyStyle),
          SizedBox(height: 20),
          ElevatedButton(
            onPressed: () => getDeviceInfo(),
            child: Text('Osvježi'),
          ),
          SizedBox(height: 20),
          ElevatedButton(
            onPressed: () => openPrepareUpdateDialog(context),
            child: Text('Ažuriraj program'),
          ),
        ],
      ),
    );
  }

  @override
  void dispose() {
    super.dispose();
  }
}
