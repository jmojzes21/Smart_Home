import 'package:air_quality_app/logic/exceptions.dart';
import 'package:air_quality_app/logic/services/real/air_quality_service.dart';
import 'package:air_quality_app/logic/vm/home_page_view_model.dart';
import 'package:air_quality_app/pages/exception_page.dart';
import 'package:flutter/material.dart';
import 'package:air_quality_app/widgets/navigation_drawer.dart';
import 'package:provider/provider.dart';

class HomePage extends StatelessWidget {
  const HomePage({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: Text('Kvaliteta zraka')),
      drawer: AppNavigationDrawer(),
      body: ChangeNotifierProvider(
        create: (context) => HomePageViewModel(aqService: AirQualityService()),
        //child: buildBody(context),
        child: Consumer<HomePageViewModel>(builder: (context, model, child) => buildBody(context, model)),
      ),
    );
  }

  Widget buildBody(BuildContext context, HomePageViewModel model) {
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
                image: getImage('assets/temperature.png'),
                text: Text('${model.airQuality.temperature.toStringAsFixed(1)} °C', style: textTheme.titleLarge),
                progress: model.temperatureProgress,
                progressColor: Color(0xFFFF485D),
              ),
              _Card(
                image: getImage('assets/humidity.png'),
                text: Text('${model.airQuality.humidity.round()} %', style: textTheme.titleLarge),
                progress: model.humidityProgress,
                progressColor: Color(0xFF0A64EA),
              ),
              _Card(
                image: getImage('assets/cloudy.png'),
                text: Text('${model.airQuality.pressure.toStringAsFixed(1)} hPa', style: textTheme.titleLarge),
                progress: model.pressureProgress,
                progressColor: Color(0xFFFCCA05),
              ),
              _Card(
                image: getImage('assets/wind.png'),
                text: RichText(
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
                progressColor: Color(0xFF0A64EA),
              ),
              FilledButton(
                onPressed: () async {
                  try {
                    await model.getAirQuality();
                  } on AppException catch (e) {
                    if (!context.mounted) return;
                    Navigator.of(
                      context,
                    ).pushReplacement(MaterialPageRoute(builder: (context) => ExceptionPage(e.message)));
                  }
                },
                child: Text('Dohvati kvalitetu zraka'),
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
  final Widget text;

  final double progress;
  final Color progressColor;

  const _Card({required this.image, required this.text, required this.progress, required this.progressColor});

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
              text,
              SizedBox(height: 5),
              LinearProgressIndicator(
                color: progressColor,
                backgroundColor: Color(0xFFEBEBEB),
                minHeight: 10,
                borderRadius: BorderRadius.circular(5),
                value: progress,
              ),
            ],
          ),
        ),
      ],
    );
  }
}
