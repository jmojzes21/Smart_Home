import 'package:air_quality_app/widgets/hyperlink.dart';
import 'package:air_quality_app/widgets/navigation_drawer.dart';
import 'package:flutter/material.dart';

class AboutPage extends StatelessWidget {
  const AboutPage({super.key});

  @override
  Widget build(BuildContext context) {
    var textTheme = Theme.of(context).textTheme;
    return Scaffold(
      appBar: AppBar(title: Text('O aplikaciji')),
      drawer: AppNavigationDrawer(),
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
              SizedBox(height: 20),

              Text('Korištene ikone', style: textTheme.titleLarge),
              _IconCredits(imageName: 'assets/temperature.png', url: 'https://www.flaticon.com/free-icon/temperature_107818'),
              _IconCredits(imageName: 'assets/humidity.png', url: 'https://www.flaticon.com/free-icon/humidity_728093'),
              _IconCredits(imageName: 'assets/cloud.png', url: 'https://www.flaticon.com/free-icon/cloud_2929984'),
              _IconCredits(imageName: 'assets/wind.png', url: 'https://www.flaticon.com/free-icon/wind_2011448'),
            ],
          ),
        ),
      ),
    );
  }
}

class _IconCredits extends StatelessWidget {
  final String imageName;
  final String url;

  const _IconCredits({required this.imageName, required this.url});

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: EdgeInsets.only(top: 10),
      child: ListTile(
        contentPadding: EdgeInsets.all(0),
        leading: Image.asset(imageName),
        title: Hyperlink(text: url, url: url),
      ),
    );
  }
}
