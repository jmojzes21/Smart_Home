import 'package:flutter/material.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';
import 'package:provider/provider.dart';
import 'package:smart_home_core/extensions.dart';
import 'package:smart_home_core/models.dart' show AppContext;
import 'package:smart_home_core/widgets.dart';

import '../logic/vm/aq_data_page_vm.dart';
import '../models/aq_chart_data.dart';
import '../models/aq_device_context.dart';
import '../widgets/custom_app_bar.dart';
import '../widgets/metrics_charts.dart';
import 'aq_data_common.dart';

class AqHistoryDataPage extends StatelessWidget {
  const AqHistoryDataPage({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: CustomAppBar(title: Text('Povijesni podaci')),
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
          return model;
        },
        child: Consumer<AirQualityDataPageViewModel>(builder: (context, model, child) => buildBody(context, model)),
      ),
    );
  }

  Widget buildBody(BuildContext context, AirQualityDataPageViewModel model) {
    bool isMobile = AppContext.instance.isMobile;
    bool enableButtons = !model.isLoading;

    return SingleChildScrollView(
      child: Padding(
        padding: EdgeInsets.all(isMobile ? 20 : 40),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            DateTimePicker(
              value: model.historyStartDate,
              firstDate: DateTime(2020),
              lastDate: DateTime(2030),
              onUpdate: (value) => model.setHistoryStartDate(value),
              label: Text('Početni datum'),
            ),
            SizedBox(height: 20),
            DateTimePicker(
              value: model.historyEndDate,
              firstDate: DateTime(2020),
              lastDate: DateTime(2030),
              defaultTime: TimeOfDay(hour: 23, minute: 59),
              onUpdate: (value) => model.setHistoryEndDate(value),
              label: Text('Završni datum'),
            ),
            SizedBox(height: 20),

            Row(
              spacing: 20,
              children: [
                MenuAnchor(
                  menuChildren: [
                    MenuItemButton(onPressed: () => selectTodayRange(model), child: Text('Danas')),
                    MenuItemButton(
                      onPressed: () => selectRangeLast(model, Duration(hours: 24)),
                      child: Text('Posljednja 24 sata'),
                    ),
                    MenuItemButton(
                      onPressed: () => selectRangeLast(model, Duration(days: 2)),
                      child: Text('Posljednja 2 dana'),
                    ),
                    MenuItemButton(
                      onPressed: () => selectRangeLast(model, Duration(days: 7)),
                      child: Text('Posljednjih tjedan dana'),
                    ),
                    MenuItemButton(
                      onPressed: () => selectRangeLast(model, Duration(days: 14)),
                      child: Text('Posljednja 2 tjedna'),
                    ),
                  ],
                  builder: (context, controller, child) {
                    return TextButton(
                      onPressed: () {
                        if (controller.isOpen) {
                          controller.close();
                        } else {
                          controller.open();
                        }
                      },
                      child: Text('Odaberite vremenski raspon'),
                    );
                  },
                ),

                FilledButton(onPressed: enableButtons ? () => model.showHistoryData() : null, child: Text('Prikaži')),
              ],
            ),

            SizedBox(height: 40),
            ...buildChart(context, model),
          ],
        ),
      ),
    );
  }

  List<Widget> buildChart(BuildContext context, AirQualityDataPageViewModel model) {
    if (model.isLoading) {
      return [Center(child: CircularProgressIndicator())];
    }

    AqChartData? aqData = model.aqData;
    if (aqData == null) {
      return [];
    }

    if (aqData.data.isEmpty) {
      return [
        Padding(
          padding: EdgeInsets.symmetric(vertical: 20),
          child: Center(child: Text('Nema podataka za prikazati.', style: context.textTheme.titleLarge)),
        ),
      ];
    }

    return [
      AirQualityCharts(aqData: aqData),
      SizedBox(height: 40),
      OutlinedButton.icon(
        onPressed: () => saveAirQualityHistoryData(context, model),
        icon: FaIcon(FontAwesomeIcons.floppyDisk),
        label: Text('Spremi podatke'),
      ),
    ];
  }

  void selectTodayRange(AirQualityDataPageViewModel model) {
    var now = DateTime.now();
    var start = DateTime(now.year, now.month, now.day, 0, 0, 0);

    model.setHistoryRange(start, now);
  }

  void selectRangeLast(AirQualityDataPageViewModel model, Duration d) {
    var now = DateTime.now();
    var start = now.subtract(d);

    model.setHistoryRange(start, now);
  }
}
