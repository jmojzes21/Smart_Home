import 'package:flutter/material.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';
import 'package:provider/provider.dart';
import 'package:smart_home_core/extensions.dart';
import 'package:smart_home_core/formats.dart';
import 'package:smart_home_core/widgets.dart';

import '../logic/vm/settings_page_vm.dart';
import '../models/aq_device_context.dart';

class SettingsPage extends StatelessWidget {
  const SettingsPage({super.key});

  @override
  Widget build(BuildContext context) {
    return ChangeNotifierProvider(
      create: (context) {
        var deviceContext = AqDeviceContext.of(context);
        return SettingsPageViewModel(
          deviceService: deviceContext.serviceFactory.getDeviceService(),
          onShowMessage: (message) {
            if (!context.mounted) return;
            Dialogs.showSnackBar(context, message);
          },
        );
      },
      child: Consumer<SettingsPageViewModel>(builder: (context, model, child) => buildBody(context, model)),
    );
  }

  Widget buildBody(BuildContext context, SettingsPageViewModel model) {
    if (model.deviceStatus == null) {
      return Center(child: CircularProgressIndicator());
    }

    var textTheme = context.textTheme;
    var titleStyle = textTheme.titleLarge;
    return SingleChildScrollView(
      child: Padding(
        padding: EdgeInsets.all(20),
        child: Column(
          children: [
            ExpansionTile(
              title: Text('Osnovno', style: titleStyle),
              expandedCrossAxisAlignment: CrossAxisAlignment.start,
              expandedAlignment: Alignment.topLeft,
              childrenPadding: EdgeInsets.all(20),
              initiallyExpanded: true,
              children: buildDeviceStatusSection(context, model),
            ),
          ],
        ),
      ),
    );
  }

  List<Widget> buildDeviceStatusSection(BuildContext context, SettingsPageViewModel model) {
    var textTheme = context.textTheme;
    var titleStyle = textTheme.titleMedium;
    var valueStyle = textTheme.bodyMedium;

    var deviceStatus = model.deviceStatus!;

    var enableButons = !model.isLoading;

    const columnSpacing = SizedBox();
    const rowDivider = TableRow(children: [Divider(), Divider(), Divider()]);

    return [
      Table(
        columnWidths: {0: IntrinsicColumnWidth(), 1: FixedColumnWidth(20), 2: FlexColumnWidth()},
        children: [
          TableRow(
            children: [
              Text('Naziv', style: titleStyle),
              columnSpacing,
              Text(deviceStatus.name, style: valueStyle),
            ],
          ),
          rowDivider,
          TableRow(
            children: [
              Text('Hostname', style: titleStyle),
              columnSpacing,
              Text(deviceStatus.hostname, style: valueStyle),
            ],
          ),
          rowDivider,
          TableRow(
            children: [
              Text('Verzija', style: titleStyle),
              columnSpacing,
              Text(deviceStatus.version, style: valueStyle),
            ],
          ),
          rowDivider,
          TableRow(
            children: [
              Text('IP adresa', style: titleStyle),
              columnSpacing,
              Text(deviceStatus.ipAddress, style: valueStyle),
            ],
          ),
          rowDivider,
          TableRow(
            children: [
              Text('WiFi mreža', style: titleStyle),
              columnSpacing,
              Text(deviceStatus.ssid, style: valueStyle),
            ],
          ),
          rowDivider,
          TableRow(
            children: [
              Text('WiFi RSSI', style: titleStyle),
              columnSpacing,
              Text('${deviceStatus.rssi} dBm', style: valueStyle),
            ],
          ),
          rowDivider,
          TableRow(
            children: [
              Text('Vrijeme', style: titleStyle),
              columnSpacing,
              Text(Formats.formatDateTime(model.rtcTime), style: valueStyle),
            ],
          ),
          rowDivider,
          TableRow(
            children: [
              Text('Napon', style: titleStyle),
              columnSpacing,
              Text('${model.voltage.toStringAsFixed(1)} V', style: valueStyle),
            ],
          ),
          rowDivider,
          TableRow(
            children: [
              Text('Heap', style: titleStyle),
              columnSpacing,
              Column(
                mainAxisSize: MainAxisSize.min,
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text('Ukupno: ${model.heapSize.toStringAsFixed(1)} KB', style: valueStyle),
                  Text(
                    'Iskorišteno: ${model.usedHeap.toStringAsFixed(1)} KB (${model.usedHeapPercent.round()}%)',
                    style: valueStyle,
                  ),
                  Text(
                    'Slobodno: ${model.freeHeap.toStringAsFixed(1)} KB (${model.freeHeapPercent.round()}%)',
                    style: valueStyle,
                  ),
                  Text(
                    'Max iskorišteno: ${model.maxUsedHeap.toStringAsFixed(1)} KB (${model.maxUsedHeapPercent.round()}%)',
                    style: valueStyle,
                  ),
                ],
              ),
            ],
          ),
        ],
      ),

      SizedBox(height: 40),
      OutlinedButton.icon(
        onPressed: enableButons ? () => model.refresh() : null,
        icon: FaIcon(FontAwesomeIcons.arrowsRotate),
        label: Text('Osvježi'),
      ),
      SizedBox(height: 20),
      OutlinedButton.icon(
        onPressed: enableButons ? () => model.syncRtcTime() : null,
        icon: FaIcon(FontAwesomeIcons.clock),
        label: Text('Sinkroniziraj vrijeme'),
      ),
    ];
  }
}
