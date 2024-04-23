import 'package:flutter/material.dart';
import 'package:smart_leds_app/widgets/navigation_drawer.dart';

class PowerSensorPage extends StatefulWidget {
  const PowerSensorPage({super.key});
  @override
  State<PowerSensorPage> createState() => _PowerSensorPageState();
}

class _PowerSensorPageState extends State<PowerSensorPage> {
  @override
  void initState() {
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Potrošnja energije'),
      ),
      drawer: AppNavigationDrawer(),
    );
  }

  @override
  void dispose() {
    super.dispose();
  }
}
