import 'package:flutter/material.dart';
import 'package:shtc3_sensor_app/pages/device_discovery_page.dart';

void main() {
  runApp(const MainApp());
}

class MainApp extends StatelessWidget {
  const MainApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      debugShowCheckedModeBanner: false,
      theme: ThemeData(colorSchemeSeed: Colors.blue),
      home: DeviceDiscoveryPage(),
    );
  }
}
