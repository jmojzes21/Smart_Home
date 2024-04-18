import 'package:flutter/material.dart';
import 'package:smart_leds_app/widgets/navigation_drawer.dart';

class HomePage extends StatefulWidget {
  const HomePage({super.key});
  @override
  State<HomePage> createState() => _HomePageState();
}

class _HomePageState extends State<HomePage> {
  @override
  void initState() {
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Početna'),
      ),
      drawer: AppNavigationDrawer(),
    );
  }

  @override
  void dispose() {
    super.dispose();
  }
}
