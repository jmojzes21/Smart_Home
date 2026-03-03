import 'package:flutter/material.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';
import 'package:provider/provider.dart';
import 'package:smart_home_core/extensions.dart';
import 'package:smart_home_core/formats.dart';
import 'package:smart_home_core/models.dart';
import 'package:smart_home_core/widgets.dart';

import '../logic/vm/aq_data_page_vm.dart';
import '../models/aq_device_context.dart';
import '../models/aq_chart_data.dart';
import '../widgets/custom_app_bar.dart';
import '../widgets/metrics_charts.dart';
import 'aq_data_common.dart';

class AqRecentDataPage extends StatelessWidget {
  const AqRecentDataPage({super.key});

  void clearData(BuildContext context, AirQualityDataPageViewModel model) async {
    bool result = await Dialogs.showConfirmDialog(context, 'Jeste li sigurni da želite obrisati nedavnu povijest?');
    if (!result || !context.mounted) return;

    model.clearRecentHistory();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: CustomAppBar(title: Text('Nedavni podaci')),
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
          model.showRecentData();

          return model;
        },
        child: Consumer<AirQualityDataPageViewModel>(builder: (context, model, child) => buildBody(context, model)),
      ),
    );
  }

  Widget buildBody(BuildContext context, AirQualityDataPageViewModel model) {
    bool isMobile = AppContext.instance.isMobile;

    if (model.isLoading) {
      return Center(child: CircularProgressIndicator());
    }

    AqChartData? aqData = model.aqData;
    if (aqData == null) {
      return SizedBox();
    }

    if (aqData.data.isEmpty) {
      return Padding(
        padding: EdgeInsets.symmetric(vertical: 20),
        child: Center(child: Text('Nema podataka za prikazati.', style: context.textTheme.titleLarge)),
      );
    }

    var textTheme = context.textTheme;

    return SingleChildScrollView(
      child: Padding(
        padding: EdgeInsets.all(isMobile ? 20 : 40),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text('Datum', style: textTheme.titleLarge),
            Text(Formats.formatDate(model.getRecentHistoryDate()), style: textTheme.titleMedium),

            SizedBox(height: 40),

            AirQualityCharts(aqData: aqData),
            SizedBox(height: 40),
            OutlinedButton.icon(
              onPressed: () => saveAirQualityHistoryData(context, model),
              icon: FaIcon(FontAwesomeIcons.floppyDisk),
              label: Text('Spremi podatke'),
            ),

            SizedBox(height: 20),
            OutlinedButton.icon(
              onPressed: () => clearData(context, model),
              icon: FaIcon(FontAwesomeIcons.trash),
              label: Text('Obriši nedavnu povijest'),
            ),
          ],
        ),
      ),
    );
  }
}
