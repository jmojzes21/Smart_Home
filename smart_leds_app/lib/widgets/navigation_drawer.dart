import 'package:flutter/material.dart';
import 'package:smart_leds_app/logic/device_service.dart';
import 'package:smart_leds_app/pages/device_discovery/device_discovery.dart';
import 'package:smart_leds_app/pages/device_info/device_info.dart';
import 'package:smart_leds_app/pages/home/home.dart';
import 'package:smart_leds_app/pages/power_sensor/power_sensor.dart';
import 'package:smart_leds_app/pages/settings/settings.dart';

import '../models/device/device.dart';

class AppNavigationDrawer extends StatelessWidget {
  const AppNavigationDrawer({super.key});

  void openHomePage(BuildContext context) {
    Navigator.of(context).pushReplacement(
      MaterialPageRoute(
        builder: (context) {
          return HomePage();
        },
      ),
    );
  }

  void openPowerSensorPage(BuildContext context) {
    Navigator.of(context).pushReplacement(
      MaterialPageRoute(
        builder: (context) {
          return PowerSensorPage();
        },
      ),
    );
  }

  void openDeviceInfo(BuildContext context) {
    Navigator.of(context).pushReplacement(
      MaterialPageRoute(
        builder: (context) {
          return DeviceInfoPage();
        },
      ),
    );
  }

  void openSettings(BuildContext context) {
    Navigator.of(context).pushReplacement(
      MaterialPageRoute(
        builder: (context) {
          return SettingsPage();
        },
      ),
    );
  }

  void closeDevice(BuildContext context) async {
    var deviceService = DeviceService();
    await deviceService.deleteSession();

    if (!context.mounted) return;
    Navigator.of(context).pushReplacement(
      MaterialPageRoute(
        builder: (context) {
          return DeviceDiscoveryPage();
        },
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    var device = Device.currentDevice;

    return Drawer(
      width: 300,
      child: Padding(
        padding: const EdgeInsets.fromLTRB(20, 40, 20, 20),
        child: Column(
          children: [
            ListTile(
              title: Text('Početna'),
              leading: Icon(Icons.home),
              onTap: () => openHomePage(context),
            ),
            ListTile(
              title: Text('Potrošnja energije'),
              leading: Icon(Icons.battery_charging_full),
              onTap: () => openPowerSensorPage(context),
            ),
            ListTile(
              title: Text('Postavke'),
              leading: Icon(Icons.settings),
              onTap: () => openSettings(context),
            ),
            Spacer(),
            ListTile(
              title: Text('Uređaj'),
              subtitle: Text(device.ipAddress.address),
              leading: Icon(Icons.devices),
              onTap: () => openDeviceInfo(context),
            ),
            ListTile(
              title: Text('Zatvori uređaj'),
              leading: Icon(Icons.logout),
              onTap: () => closeDevice(context),
            ),
          ],
        ),
      ),
    );
  }
}
