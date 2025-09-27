import '../logic/services/service_factory.dart';
import '../logic/vm/home_page_view_model.dart';
import 'exception_page.dart';
import 'package:flutter/material.dart';
import '../widgets/navigation_drawer.dart';
import 'package:provider/provider.dart';

class HomePage extends StatelessWidget {
  const HomePage({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: Text('Kvaliteta zraka')),
      drawer: AppNavigationDrawer(),
      body: ChangeNotifierProvider(
        create: (context) => HomePageViewModel(
          aqService: ServiceFactory.getAirQualityService(),
          openExceptionPage: (message) {
            Navigator.of(context).pushReplacement(MaterialPageRoute(builder: (context) => ExceptionPage(message)));
          },
        ),
        //child: buildBody(context),
        child: Consumer<HomePageViewModel>(builder: (context, model, child) => buildBody(context, model)),
      ),
    );
  }

  Widget buildBody(BuildContext context, HomePageViewModel model) {
    if (model.isLoading) {
      return Center(child: CircularProgressIndicator());
    }

    var textTheme = Theme.of(context).textTheme;
    return SingleChildScrollView(
      child: Padding(
        padding: EdgeInsets.all(40),
        child: Center(
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            crossAxisAlignment: CrossAxisAlignment.center,
            spacing: 40,
            children: [
              _Card(
                image: getImage('assets/air_quality/temperature.png'),
                title: Text('Temperatura', style: textTheme.titleMedium),
                valueText: Text('${model.airQuality.temperature.toStringAsFixed(1)} °C', style: textTheme.titleLarge),
                progress: model.temperatureProgress,
                progressColor: Color(0xFFFF485D),
              ),
              _Card(
                image: getImage('assets/air_quality/humidity.png'),
                title: Text('Vlaga', style: textTheme.titleMedium),
                valueText: Text('${model.airQuality.humidity.round()} %', style: textTheme.titleLarge),
                progress: model.humidityProgress,
                progressColor: Color(0xFF0A64EA),
              ),
              _Card(
                image: getImage('assets/air_quality/cloud.png'),
                title: Text('Tlak', style: textTheme.titleMedium),
                valueText: Text('${model.airQuality.pressure.toStringAsFixed(1)} hPa', style: textTheme.titleLarge),
                progress: model.pressureProgress,
                progressColor: Color(0xFFFCCA05),
              ),
              _Card(
                image: getImage('assets/air_quality/wind.png'),
                title: Text('PM2.5', style: textTheme.titleMedium),
                valueText: RichText(
                  text: TextSpan(
                    style: textTheme.titleLarge,
                    children: [
                      TextSpan(text: '${model.airQuality.pm25} µg/m'),
                      TextSpan(
                        text: '3',
                        style: textTheme.titleLarge!.copyWith(fontFeatures: [FontFeature.superscripts()]),
                      ),
                    ],
                  ),
                ),
                progress: model.pm25Progress,
                progressColor: Color(0xFF0094FF),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget getImage(String name) {
    return Image.asset(name, width: 80, height: 80, filterQuality: FilterQuality.medium);
  }
}

class _Card extends StatelessWidget {
  final Widget image;
  final Widget title;
  final Widget valueText;

  final double progress;
  final Color progressColor;

  const _Card({required this.image, required this.title, required this.valueText, required this.progress, required this.progressColor});

  @override
  Widget build(BuildContext context) {
    return Row(
      crossAxisAlignment: CrossAxisAlignment.center,
      children: [
        image,
        SizedBox(width: 20),
        Expanded(
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              title,
              valueText,
              SizedBox(height: 10),
              LinearProgressIndicator(color: progressColor, backgroundColor: Color(0xFFEBEBEB), minHeight: 10, borderRadius: BorderRadius.circular(5), value: progress),
            ],
          ),
        ),
      ],
    );
  }
}
