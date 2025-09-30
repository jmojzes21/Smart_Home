import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:smart_home_core/models.dart';

import 'pages/devices_page.dart';

void main() {
  runApp(const MainApp());
}

class MainApp extends StatelessWidget {
  const MainApp({super.key});

  @override
  Widget build(BuildContext context) {
    return Provider(
      create: (context) => DeviceContext(),
      child: MaterialApp(
        debugShowCheckedModeBanner: false,
        theme: ThemeData(colorSchemeSeed: Colors.blue),
        home: DevicesPage(),
      ),
    );
  }
}
