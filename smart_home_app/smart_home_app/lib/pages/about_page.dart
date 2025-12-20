import 'package:flutter/material.dart';

class AboutPage extends StatelessWidget {
  const AboutPage({super.key});

  @override
  Widget build(BuildContext context) {
    var textTheme = Theme.of(context).textTheme;
    return Scaffold(
      appBar: AppBar(title: Text('O aplikaciji')),
      body: SingleChildScrollView(
        child: Padding(
          padding: EdgeInsets.all(40),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text('Autor', style: textTheme.titleLarge),
              ListTile(
                leading: Icon(Icons.person, color: Colors.blue.shade800),
                title: Text('Josip Mojzeš'),
                contentPadding: EdgeInsets.all(0),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
