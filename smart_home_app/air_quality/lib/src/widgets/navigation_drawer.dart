import '../pages/about_page.dart';
import 'package:flutter/material.dart';
import '../pages/home_page.dart';

class AppNavigationDrawer extends StatelessWidget {
  const AppNavigationDrawer({super.key});

  void openHomePage(BuildContext context) {
    Navigator.of(context).pushReplacement(MaterialPageRoute(builder: (context) => HomePage()));
  }

  void openAboutPage(BuildContext context) {
    Navigator.of(context).pushReplacement(MaterialPageRoute(builder: (context) => AboutPage()));
  }

  void openSettingsPage(BuildContext context) {}

  void closeDevice(BuildContext context) {
    Navigator.of(context).pop();
    Navigator.of(context).pop();
  }

  @override
  Widget build(BuildContext context) {
    return NavigationDrawer(
      children: [
        ListTile(onTap: () => openHomePage(context), title: Text('Početna'), leading: Icon(Icons.home)),
        ListTile(onTap: () => openAboutPage(context), title: Text('O aplikaciji'), leading: Icon(Icons.info)),
        ListTile(onTap: () => openSettingsPage(context), title: Text('Postavke'), leading: Icon(Icons.settings)),
        ListTile(onTap: () => closeDevice(context), title: Text('Zatvori uređaj'), leading: Icon(Icons.exit_to_app)),
      ],
    );
  }
}
