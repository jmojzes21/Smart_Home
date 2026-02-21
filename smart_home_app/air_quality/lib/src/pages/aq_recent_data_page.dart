import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:smart_home_core/widgets.dart';

import '../logic/vm/aq_data_page_vm.dart';
import '../models/aq_device_context.dart';
import '../models/aq_chart_data.dart';
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
            aqService: deviceContext.airQualityService,
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

    AqChartData? aqData = model.aqData;
    if (aqData == null) {
      return SizedBox();
    }

    return SingleChildScrollView(
      child: Padding(
        padding: EdgeInsets.all(20),
        child: Center(child: AirQualityCharts(aqData: aqData)),
      ),
    );
  }
}
