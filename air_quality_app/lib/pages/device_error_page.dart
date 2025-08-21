import 'package:flutter/material.dart';
import 'package:air_quality_app/pages/device_page.dart';

class DeviceErrorPage extends StatelessWidget {
  final String errorMessage;

  const DeviceErrorPage(this.errorMessage, {super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: Text('Greška')),
      body: Padding(
        padding: EdgeInsets.all(20),
        child: Center(
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            crossAxisAlignment: CrossAxisAlignment.center,
            children: [
              Text(errorMessage),
              SizedBox(height: 20),
              FilledButton(
                onPressed: () {
                  Navigator.of(context).pushReplacement(MaterialPageRoute(builder: (context) => DevicePage()));
                },
                child: Text('Pokušaj ponovno'),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
