import 'package:flutter/material.dart';
import 'package:smart_leds_app/pages/device_discovery_page.dart';
import 'package:smart_leds_app/pages/device_info_page.dart';
import 'package:smart_leds_app/pages/home_page.dart';

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

  void openEnergyPage(BuildContext context) {
    Navigator.of(context).pushReplacement(
      MaterialPageRoute(
        builder: (context) {
          return HomePage();
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
          return HomePage();
        },
      ),
    );
  }

  void closeDevice(BuildContext context) {
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
              onTap: () => openEnergyPage(context),
            ),
            ListTile(
              title: Text('O uređaju'),
              leading: Icon(Icons.devices),
              onTap: () => openDeviceInfo(context),
            ),
            ListTile(
              title: Text('Postavke'),
              leading: Icon(Icons.settings),
              onTap: () => openSettings(context),
            ),
            Spacer(),
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
