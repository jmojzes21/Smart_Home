import 'package:smart_home_core/models.dart';
import 'package:smart_home_core/widgets.dart';

import '../logic/vm/home_page_vm.dart';
import '../models/aq_device_context.dart';
import '../widgets/custom_app_bar.dart';
import '../widgets/metrics_card.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

class HomePage extends StatelessWidget {
  const HomePage({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: CustomAppBar(title: Text('Kvaliteta zraka')),
      body: ChangeNotifierProvider(
        create: (context) {
          var deviceContext = AqDeviceContext.of(context);
          return HomePageViewModel(
            aqService: deviceContext.airQualityService,
            onException: (message) {
              if (!context.mounted) return;
              Dialogs.showSnackBar(context, message);
            },
          );
        },
        //child: buildBody(context),
        child: Consumer<HomePageViewModel>(builder: (context, model, child) => buildBody(context, model)),
      ),
    );
  }

  Widget buildBody(BuildContext context, HomePageViewModel model) {
    if (model.isLoading || model.airQuality == null) {
      return Center(child: CircularProgressIndicator());
    }

    return Center(
      child: SingleChildScrollView(child: Center(child: buildMetrics(context, model))),
    );
  }

  Widget buildMetrics(BuildContext context, HomePageViewModel model) {
    var textTheme = Theme.of(context).textTheme;
    bool isMobile = AppContext.instance.isMobile;

    double mcPadding = isMobile ? 10 : 20;
    double mcImgSpacing = isMobile ? 10 : 20;

    double mcWidth = isMobile ? 250 : 300;
    double imgSize = isMobile ? 50 : 80;

    var mcTitleStyle = isMobile ? textTheme.bodyMedium : textTheme.titleMedium;
    var mcValueStyle = isMobile ? textTheme.bodyLarge : textTheme.titleLarge;

    var airQuality = model.airQuality!;

    var mcTemperature = MetricsCard(
      image: getImage('assets/air_quality/temperature.png', imgSize),
      title: Text('Temperatura', style: mcTitleStyle),
      value: Text('${airQuality.temperature.toStringAsFixed(1)} °C', style: mcValueStyle),
      padding: mcPadding,
      imageSpacing: mcImgSpacing,
    );

    var mcHumidity = MetricsCard(
      image: getImage('assets/air_quality/humidity.png', imgSize),
      title: Text('Vlaga', style: mcTitleStyle),
      value: Text('${airQuality.humidity.round()} %', style: mcValueStyle),
      padding: mcPadding,
      imageSpacing: mcImgSpacing,
    );

    var mcPressure = MetricsCard(
      image: getImage('assets/air_quality/cloud.png', imgSize),
      title: Text('Tlak', style: mcTitleStyle),
      value: Text('${airQuality.pressure.toStringAsFixed(1)} hPa', style: mcValueStyle),
      padding: mcPadding,
      imageSpacing: mcImgSpacing,
    );

    var mcPm25 = MetricsCard(
      image: getImage('assets/air_quality/wind.png', imgSize),
      title: Text('PM2.5', style: mcTitleStyle),
      value: RichText(
        text: TextSpan(
          style: mcValueStyle,
          children: [
            TextSpan(text: '${airQuality.pm25} µg/m'),
            TextSpan(
              text: '3',
              style: mcValueStyle!.copyWith(fontFeatures: [FontFeature.superscripts()]),
            ),
          ],
        ),
      ),
      padding: mcPadding,
      imageSpacing: mcImgSpacing,
    );

    return Padding(
      padding: EdgeInsets.all(isMobile ? 20 : 40),
      child: Wrap(
        runSpacing: isMobile ? 20 : 40,
        spacing: isMobile ? 20 : 40,
        children: [
          SizedBox(width: mcWidth, child: mcTemperature),
          SizedBox(width: mcWidth, child: mcHumidity),
          SizedBox(width: mcWidth, child: mcPressure),
          SizedBox(width: mcWidth, child: mcPm25),
        ],
      ),
    );
  }

  Widget getImage(String name, double size) {
    return Image.asset(name, width: size, height: size, filterQuality: FilterQuality.medium);
  }
}
