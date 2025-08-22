import 'package:flutter/material.dart';
import 'package:air_quality_app/pages/home_page.dart';

class AppNavigationDrawer extends StatelessWidget {
  const AppNavigationDrawer({super.key});

  void openHomePage(BuildContext context) {
    Navigator.of(context).pushReplacement(MaterialPageRoute(builder: (context) => HomePage()));
  }

  void openSettingsPage(BuildContext context) {}

  @override
  Widget build(BuildContext context) {
    return NavigationDrawer(
      children: [
        ListTile(onTap: () => openHomePage(context), title: Text('Početna'), leading: Icon(Icons.home)),
        ListTile(onTap: () => openSettingsPage(context), title: Text('Postavke'), leading: Icon(Icons.settings)),
      ],
    );
  }
}
