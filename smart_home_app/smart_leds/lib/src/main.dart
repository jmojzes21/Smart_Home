import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'logic/providers/pattern_provider.dart';
import 'pages/device_discovery.dart';

class MainApp extends StatelessWidget {
  const MainApp({super.key});

  @override
  Widget build(BuildContext context) {
    return Provider(create: (context) => PatternProvider(), child: DeviceDiscoveryPage());
  }
}
