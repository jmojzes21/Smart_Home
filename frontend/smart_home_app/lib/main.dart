import 'package:flutter/material.dart';

import 'package:air_quality/air_quality.dart' as air_quality;
import 'package:smart_leds/smart_leds.dart' as smart_leds;

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
      home: Scaffold(
        body: Builder(
          builder: (context) {
            return Center(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  TextButton(
                    onPressed: () {
                      Navigator.of(context).pushReplacement(MaterialPageRoute(builder: (context) => air_quality.HomePage()));
                    },
                    child: Text('Kvaliteta zraka'),
                  ),
                  SizedBox(height: 20),
                  TextButton(
                    onPressed: () {
                      Navigator.of(context).pushReplacement(MaterialPageRoute(builder: (context) => smart_leds.MainApp()));
                    },
                    child: Text('Pametne LEDice'),
                  ),
                ],
              ),
            );
          },
        ),
      ),
    );
  }
}
