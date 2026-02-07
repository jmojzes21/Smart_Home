import 'package:flutter/material.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';
import 'package:provider/provider.dart';
import 'package:smart_home_core/extensions.dart';
import 'package:smart_home_core/formats.dart';
import 'package:smart_home_core/widgets.dart';

import '../logic/vm/settings_page_vm.dart';
import '../models/aq_device_context.dart';
import '../widgets/custom_app_bar.dart';

class SettingsPage extends StatelessWidget {
  const SettingsPage({super.key});

  @override
  Widget build(BuildContext context) {
    /*
      Align(
          alignment: AlignmentGeometry.bottomRight,
          child: Padding(
            padding: EdgeInsets.all(20),
            child: FloatingActionButton(
              onPressed: enableButtons ? () => model.getDevices() : null,
              child: FaIcon(FontAwesomeIcons.arrowsRotate),
            ),
          ),
        ),
*/

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
      child: Consumer<SettingsPageViewModel>(
        builder: (context, model, child) {
          return Scaffold(
            appBar: CustomAppBar(title: Text('Postavke')),
            body: buildBody(context, model),
            floatingActionButton: FloatingActionButton(
              onPressed: !model.isLoading ? () => model.refresh() : null,
              child: FaIcon(FontAwesomeIcons.arrowsRotate),
            ),
          );
        },
      ),
    );
  }

  Widget buildBody(BuildContext context, SettingsPageViewModel model) {
    if (model.deviceStatus == null) {
      return Center(child: CircularProgressIndicator());
    }

    var enableButons = !model.isLoading;

    var device = model.deviceStatus!;
    var memory = device.memory;

    var textTheme = context.textTheme;
    var sectionStyle = textTheme.titleLarge;
    var keyStyle = textTheme.titleMedium;
    var valueStyle = textTheme.bodyMedium;

    const columnSpacing = SizedBox();
    const rowDivider = TableRow(children: [Divider(), Divider(), Divider()]);

    var basicInfoTable = Table(
      columnWidths: {0: IntrinsicColumnWidth(), 1: FixedColumnWidth(20), 2: FlexColumnWidth()},
      children: [
        TableRow(
          children: [
            Text('Naziv', style: keyStyle),
            columnSpacing,
            Text(device.name, style: valueStyle),
          ],
        ),
        rowDivider,
        TableRow(
          children: [
            Text('Hostname', style: keyStyle),
            columnSpacing,
            Text(device.hostname, style: valueStyle),
          ],
        ),
        rowDivider,
        TableRow(
          children: [
            Text('Verzija', style: keyStyle),
            columnSpacing,
            Text(device.version, style: valueStyle),
          ],
        ),
        rowDivider,
        TableRow(
          children: [
            Text('Napon', style: keyStyle),
            columnSpacing,
            Column(
              mainAxisSize: MainAxisSize.min,
              crossAxisAlignment: CrossAxisAlignment.start,
              spacing: 10,
              children: [
                Text(
                  '${device.inputVoltage.toStringAsFixed(1)} V (${(device.inputVoltagePercent * 100).round()}%)',
                  style: valueStyle,
                ),
                LinearProgressIndicator(value: device.inputVoltagePercent),
              ],
            ),
          ],
        ),
      ],
    );

    var wifiTable = Table(
      columnWidths: {0: IntrinsicColumnWidth(), 1: FixedColumnWidth(20), 2: FlexColumnWidth()},
      children: [
        TableRow(
          children: [
            Text('IP adresa', style: keyStyle),
            columnSpacing,
            Text(device.ipAddress, style: valueStyle),
          ],
        ),
        rowDivider,
        TableRow(
          children: [
            Text('WiFi mreža', style: keyStyle),
            columnSpacing,
            Text(device.ssid, style: valueStyle),
          ],
        ),
        rowDivider,
        TableRow(
          children: [
            Text('WiFi RSSI', style: keyStyle),
            columnSpacing,
            Text('${device.rssi} dBm', style: valueStyle),
          ],
        ),
      ],
    );

    var timeTable = Table(
      columnWidths: {0: IntrinsicColumnWidth(), 1: FixedColumnWidth(20), 2: FlexColumnWidth()},
      children: [
        TableRow(
          children: [
            Text('Trenutno', style: keyStyle),
            columnSpacing,
            Text(Formats.formatDateTime(model.currentTime), style: valueStyle),
          ],
        ),
        rowDivider,
        TableRow(
          children: [
            Text('Uređaj', style: keyStyle),
            columnSpacing,
            Text(Formats.formatDateTime(model.rtcTime), style: valueStyle),
          ],
        ),
      ],
    );

    var advancedInfoTable = Table(
      columnWidths: {0: IntrinsicColumnWidth(), 1: FixedColumnWidth(20), 2: FlexColumnWidth()},
      children: [
        TableRow(
          children: [
            Text('Heap', style: keyStyle),
            columnSpacing,
            Column(
              mainAxisSize: MainAxisSize.min,
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text('Iskorišteno', style: textTheme.titleSmall),
                Text(_memoryUsageText(memory.usedHeap, memory.heapSize, memory.usedHeapPercent), style: valueStyle),
                SizedBox(height: 10),

                LinearProgressIndicator(value: memory.usedHeapPercent),
                SizedBox(height: 10),

                Text('Max iskorišteno', style: textTheme.titleSmall),
                Text(
                  _memoryUsageText(memory.maxUsedHeap, memory.heapSize, memory.maxUsedHeapPercent),
                  style: valueStyle,
                ),
                SizedBox(height: 10),
              ],
            ),
          ],
        ),
        rowDivider,
        TableRow(
          children: [
            Text('PSRAM', style: keyStyle),
            columnSpacing,
            Column(
              mainAxisSize: MainAxisSize.min,
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text('Iskorišteno', style: textTheme.titleSmall),
                Text(_memoryUsageText(memory.usedPsram, memory.psramSize, memory.usedPsramPercent), style: valueStyle),
                SizedBox(height: 10),

                LinearProgressIndicator(value: memory.usedPsramPercent),
                SizedBox(height: 10),

                Text('Max iskorišteno', style: textTheme.titleSmall),
                Text(
                  _memoryUsageText(memory.maxUsedPsram, memory.psramSize, memory.maxUsedPsramPercent),
                  style: valueStyle,
                ),
                SizedBox(height: 10),
              ],
            ),
          ],
        ),
      ],
    );

    return SingleChildScrollView(
      child: Padding(
        padding: EdgeInsets.all(40),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            ExpansionTile(
              leading: Icon(Icons.devices),
              title: Text('Osnovno', style: sectionStyle),
              expandedCrossAxisAlignment: CrossAxisAlignment.start,
              expandedAlignment: Alignment.topLeft,
              childrenPadding: EdgeInsets.all(20),
              initiallyExpanded: false,
              children: [basicInfoTable],
            ),
            ExpansionTile(
              leading: FaIcon(FontAwesomeIcons.wifi),
              title: Text('Povezivanje', style: sectionStyle),
              expandedCrossAxisAlignment: CrossAxisAlignment.start,
              expandedAlignment: Alignment.topLeft,
              childrenPadding: EdgeInsets.all(20),
              initiallyExpanded: false,
              children: [
                wifiTable,
                SizedBox(height: 20),
                OutlinedButton.icon(
                  onPressed: enableButons ? () {} : null,
                  icon: FaIcon(FontAwesomeIcons.sliders),
                  label: Text('Upravljanje mrežama'),
                ),
              ],
            ),
            ExpansionTile(
              leading: FaIcon(FontAwesomeIcons.clock),
              title: Text('Sat', style: sectionStyle),
              expandedCrossAxisAlignment: CrossAxisAlignment.start,
              expandedAlignment: Alignment.topLeft,
              childrenPadding: EdgeInsets.all(20),
              initiallyExpanded: false,
              children: [
                timeTable,
                SizedBox(height: 20),
                OutlinedButton.icon(
                  onPressed: enableButons ? () => model.syncRtcTime() : null,
                  icon: FaIcon(FontAwesomeIcons.arrowsRotate),
                  label: Text('Sinkroniziraj vrijeme'),
                ),
              ],
            ),
            ExpansionTile(
              leading: FaIcon(FontAwesomeIcons.sliders),
              title: Text('Napredno', style: sectionStyle),
              expandedCrossAxisAlignment: CrossAxisAlignment.start,
              expandedAlignment: Alignment.topLeft,
              childrenPadding: EdgeInsets.all(20),
              initiallyExpanded: false,
              children: [advancedInfoTable],
            ),
          ],
        ),
      ),
    );
  }

  String _memoryUsageText(double used, double total, double percent) {
    return '${used.toStringAsFixed(1)} / ${total.toStringAsFixed(1)} KB (${(percent * 100).round()}%)';
  }
}
