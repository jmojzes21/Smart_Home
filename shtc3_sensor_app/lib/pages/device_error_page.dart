import 'package:flutter/material.dart';
import 'package:shtc3_sensor_app/pages/device_page.dart';

class DeviceErrorPage extends StatelessWidget {
  final String errorMessage;

  const DeviceErrorPage(this.errorMessage, {super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: Text('Greška')),
      body: Padding(
        padding: EdgeInsets.all(40),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(errorMessage),
            SizedBox(height: 20),
            Center(
              child: TextButton(
                onPressed: () {
                  Navigator.of(context).pushReplacement(MaterialPageRoute(builder: (context) => DevicePage()));
                },
                child: Text('Pokušaj ponovno'),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
