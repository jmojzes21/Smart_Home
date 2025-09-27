import '../widgets/hyperlink.dart';
import '../widgets/navigation_drawer.dart';
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
              _IconCredits(imageName: 'assets/air_quality/temperature.png', url: 'https://www.flaticon.com/free-icon/temperature_107818'),
              _IconCredits(imageName: 'assets/air_quality/humidity.png', url: 'https://www.flaticon.com/free-icon/humidity_728093'),
              _IconCredits(imageName: 'assets/air_quality/cloud.png', url: 'https://www.flaticon.com/free-icon/cloud_2929984'),
              _IconCredits(imageName: 'assets/air_quality/wind.png', url: 'https://www.flaticon.com/free-icon/wind_2011448'),
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
