import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import '../../pages/home.dart';
import '../../pages/power_sensor.dart';
import '../../pages/settings.dart';

class AppNavigationDrawer extends StatelessWidget {
  const AppNavigationDrawer({super.key});

  void openHomePage(BuildContext context) {
    Navigator.of(context).pushReplacement(
      MaterialPageRoute(
        builder: (context) {
          return const HomePage();
        },
      ),
    );
  }

  void openPowerSensorPage(BuildContext context) {
    Navigator.of(context).pushReplacement(
      MaterialPageRoute(
        builder: (context) {
          return const PowerSensorPage();
        },
      ),
    );
  }

  void openSettings(BuildContext context) {
    Navigator.of(context).pushReplacement(
      MaterialPageRoute(
        builder: (context) {
          return const SettingsPage();
        },
      ),
    );
  }

  void closeDevice(BuildContext context) async {
    if (!context.mounted) return;
    context.replace('/');
  }

  @override
  Widget build(BuildContext context) {
    return Drawer(
      width: 300,
      child: Padding(
        padding: const EdgeInsets.fromLTRB(20, 40, 20, 20),
        child: Column(
          children: [
            ListTile(title: const Text('Početna'), leading: const Icon(Icons.home), onTap: () => openHomePage(context)),
            ListTile(
              title: const Text('Potrošnja energije'),
              leading: const Icon(Icons.battery_charging_full),
              onTap: () => openPowerSensorPage(context),
            ),
            ListTile(
              title: const Text('Postavke'),
              leading: const Icon(Icons.settings),
              onTap: () => openSettings(context),
            ),
            const Spacer(),
            ListTile(
              title: const Text('Zatvori uređaj'),
              leading: const Icon(Icons.logout),
              onTap: () => closeDevice(context),
            ),
          ],
        ),
      ),
    );
  }
}
