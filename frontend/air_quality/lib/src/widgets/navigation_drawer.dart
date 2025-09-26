import 'package:air_quality/src/pages/about_page.dart';
import 'package:flutter/material.dart';
import 'package:air_quality/src/pages/home_page.dart';

class AppNavigationDrawer extends StatelessWidget {
  const AppNavigationDrawer({super.key});

  void openHomePage(BuildContext context) {
    Navigator.of(context).pushReplacement(MaterialPageRoute(builder: (context) => HomePage()));
  }

  void openAboutPage(BuildContext context) {
    Navigator.of(context).pushReplacement(MaterialPageRoute(builder: (context) => AboutPage()));
  }

  void openSettingsPage(BuildContext context) {}

  @override
  Widget build(BuildContext context) {
    return NavigationDrawer(
      children: [
        ListTile(onTap: () => openHomePage(context), title: Text('Početna'), leading: Icon(Icons.home)),
        ListTile(onTap: () => openAboutPage(context), title: Text('O aplikaciji'), leading: Icon(Icons.info)),
        ListTile(onTap: () => openSettingsPage(context), title: Text('Postavke'), leading: Icon(Icons.settings)),
      ],
    );
  }
}
