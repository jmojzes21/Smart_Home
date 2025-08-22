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
    return SingleChildScrollView(
      child: Padding(
        padding: EdgeInsets.all(40),
        child: Center(
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            crossAxisAlignment: CrossAxisAlignment.center,
            spacing: 40,
            children: [
              buildCard(
                context,
                image: 'assets/temperature_2944651.png',
                text: '${model.airQuality.temperature.toStringAsFixed(1)} °C',
                progress: model.temperatureProgress,
                progressColor: Color(0xFFFF485D),
              ),
              buildCard(
                context,
                image: 'assets/humidity_2903592.png',
                text: '${model.airQuality.humidity.round()} %',
                progress: model.humidityProgress,
                progressColor: Color(0xFF0A64EA),
              ),
              buildCard(
                context,
                image: 'assets/clouds_704845.png',
                text: '${model.airQuality.pressure.toStringAsFixed(1)} hPa',
                progress: model.pressureProgress,
                progressColor: Color(0xFFFCCA05),
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

  Widget buildCard(
    BuildContext context, {
    required String image,
    required String text,
    required double progress,
    required Color progressColor,
  }) {
    return Row(
      crossAxisAlignment: CrossAxisAlignment.center,
      children: [
        Image.asset(image, width: 80, height: 80, filterQuality: FilterQuality.medium),
        SizedBox(width: 20),
        Expanded(
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(text, style: Theme.of(context).textTheme.titleLarge),
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
