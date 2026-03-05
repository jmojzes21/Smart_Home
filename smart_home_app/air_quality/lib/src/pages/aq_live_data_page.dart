import 'package:flutter/material.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';
import 'package:provider/provider.dart';
import 'package:smart_home_core/models.dart';
import 'package:smart_home_core/widgets.dart';

import '../logic/vm/aq_data_page_vm.dart';
import '../models/aq_device_context.dart';
import '../widgets/custom_app_bar.dart';
import '../widgets/metrics_charts.dart';
import 'aq_data_common.dart';

class AqLiveDataPage extends StatelessWidget {
  const AqLiveDataPage({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: CustomAppBar(title: Text('Uživo podaci')),
      body: ChangeNotifierProvider(
        create: (context) {
          var deviceContext = AqDeviceContext.of(context);
          var model = AirQualityDataPageViewModel(
            aqService: deviceContext.airQualityService,
            onShowMessage: (message) {
              if (!context.mounted) return;
              Dialogs.showSnackBar(context, message);
            },
          );
          model.showLiveData();

          return model;
        },
        child: Consumer<AirQualityDataPageViewModel>(builder: (context, model, child) => buildBody(context, model)),
      ),
    );
  }

  Widget buildBody(BuildContext context, AirQualityDataPageViewModel model) {
    bool isMobile = AppContext.instance.isMobile;

    if (model.isLoading || model.aqData == null || model.aqData!.data.isEmpty) {
      return Center(child: CircularProgressIndicator());
    }

    return SingleChildScrollView(
      child: Padding(
        padding: EdgeInsets.all(isMobile ? 20 : 40),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            AirQualityCharts(aqData: model.aqData!),
            SizedBox(height: 40),
            OutlinedButton.icon(
              onPressed: () => saveAirQualityHistoryData(context, model),
              icon: FaIcon(FontAwesomeIcons.floppyDisk),
              label: Text('Spremi podatke'),
            ),
          ],
        ),
      ),
    );
  }
}
