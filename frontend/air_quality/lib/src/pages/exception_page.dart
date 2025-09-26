import 'package:air_quality/src/pages/home_page.dart';
import 'package:flutter/material.dart';

class ExceptionPage extends StatelessWidget {
  final String message;

  const ExceptionPage(this.message, {super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: Text('Dogodila se greška')),
      body: Padding(
        padding: EdgeInsets.all(20),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.start,
          crossAxisAlignment: CrossAxisAlignment.center,
          children: [
            Text(message),
            SizedBox(height: 20),
            FilledButton(
              onPressed: () {
                Navigator.of(context).pushReplacement(MaterialPageRoute(builder: (context) => HomePage()));
              },
              child: Text('Početna stranica'),
            ),
          ],
        ),
      ),
    );
  }
}
