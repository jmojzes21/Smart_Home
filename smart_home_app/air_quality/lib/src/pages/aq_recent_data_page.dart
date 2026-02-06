import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:smart_home_core/extensions.dart';
import 'package:smart_home_core/widgets.dart';

import '../logic/vm/local_data_page_vm.dart';
import '../models/aq_device_context.dart';
import '../models/aq_history_data.dart';
import '../widgets/custom_app_bar.dart';
import '../widgets/metrics_charts.dart';

class AqRecentDataPage extends StatelessWidget {
  const AqRecentDataPage({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: CustomAppBar(title: Text('Nedavni podaci')),
      body: ChangeNotifierProvider(
        create: (context) {
          var deviceContext = AqDeviceContext.of(context);
          return LocalDataPageVm(
            aqService: deviceContext.serviceFactory.getAirQualityService(),
            onShowMessage: (message) {
              if (!context.mounted) return;
              Dialogs.showSnackBar(context, message);
            },
          );
        },
        child: Consumer<LocalDataPageVm>(builder: (context, model, child) => buildBody(context, model)),
      ),
    );
  }

  Widget buildBody(BuildContext context, LocalDataPageVm model) {
    if (model.isLoading) {
      return Center(child: CircularProgressIndicator());
    }

    AqHistoryData? aqData = model.aqData;
    if (aqData == null) {
      return SizedBox();
    }

    var textTheme = context.textTheme;
    var titleStyle = textTheme.titleLarge;

    return SingleChildScrollView(
      child: Padding(
        padding: EdgeInsets.all(40),
        child: Center(
          child: Wrap(
            spacing: 20,
            runSpacing: 20,
            children: [
              buildChart(Text('Temperatura', style: titleStyle), TemperatureChart(aqData: aqData)),
              buildChart(Text('Vlaga', style: titleStyle), HumidityChart(aqData: aqData)),
              buildChart(Text('Tlak', style: titleStyle), PressureChart(aqData: aqData)),
              buildChart(Text('PM2.5', style: titleStyle), Pm25Chart(aqData: aqData)),
            ],
          ),
        ),
      ),
    );
  }

  Widget buildChart(Widget title, Widget chart) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.center,
      children: [
        title,
        SizedBox(height: 20),
        ConstrainedBox(
          constraints: BoxConstraints(maxWidth: 500),
          child: AspectRatio(aspectRatio: 2, child: chart),
        ),
      ],
    );
  }
}
