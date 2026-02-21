import 'package:flutter/material.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';
import 'package:provider/provider.dart';
import 'package:smart_home_core/extensions.dart';
import 'package:smart_home_core/formats.dart';
import 'package:smart_home_core/widgets.dart';

import '../logic/vm/settings_page_vm.dart';
import '../models/aq_device_context.dart';
import '../models/device_config.dart';
import '../widgets/custom_app_bar.dart';
import '../widgets/edit_wifi_net_dialog.dart';

class SettingsPage extends StatelessWidget {
  final double lpiHeight = 6;
  final double lpiMaxWidth = 200;

  const SettingsPage({super.key});

  @override
  Widget build(BuildContext context) {
    return ChangeNotifierProvider(
      create: (context) {
        var deviceContext = AqDeviceContext.of(context);
        return SettingsPageViewModel(
          deviceService: deviceContext.deviceService,
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
    if (model.isLoading && model.deviceStatus == null) {
      return Center(child: CircularProgressIndicator());
    }

    var enableButtons = !model.isLoading;

    return SingleChildScrollView(
      child: Padding(
        padding: EdgeInsets.all(40),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            buildBasicInfoSection(context, model),
            buildWifiSection(context, model, enableButtons),
            buildRtcSection(context, model, enableButtons),
            buildAdvancedSection(context, model),

            SizedBox(height: 20),

            OutlinedButton.icon(
              onPressed: enableButtons ? () => model.restartDevice() : null,
              icon: FaIcon(FontAwesomeIcons.arrowRotateLeft),
              label: Text('Ponovno pokreni uređaj'),
            ),

            SizedBox(height: 20),
            Row(
              spacing: 20,
              children: [
                FilledButton(
                  onPressed: enableButtons && model.shouldSaveChanges
                      ? () {
                          model.updateSettings();
                        }
                      : null,
                  child: Text('Spremi promjene'),
                ),
                TextButton(
                  onPressed: enableButtons && model.shouldSaveChanges
                      ? () {
                          model.refresh();
                        }
                      : null,
                  child: Text('Poništi promjene'),
                ),
              ],
            ),
            SizedBox(height: 80),
          ],
        ),
      ),
    );
  }

  Widget buildBasicInfoSection(BuildContext context, SettingsPageViewModel model) {
    var device = model.deviceStatus!;

    var textTheme = context.textTheme;
    var sectionStyle = textTheme.titleMedium;
    var keyStyle = textTheme.titleMedium;
    var valueStyle = textTheme.bodyMedium;

    const columnSpacing = SizedBox();
    const rowDivider = TableRow(children: [Divider(), Divider(), Divider()]);

    return ExpansionTile(
      leading: Icon(Icons.devices),
      title: Text('Osnovno', style: sectionStyle),
      expandedCrossAxisAlignment: CrossAxisAlignment.start,
      expandedAlignment: Alignment.topLeft,
      childrenPadding: EdgeInsets.all(20),
      initiallyExpanded: false,
      children: [
        Table(
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
                    ConstrainedBox(
                      constraints: BoxConstraints(maxWidth: lpiMaxWidth),
                      child: LinearProgressIndicator(value: device.inputVoltagePercent, minHeight: lpiHeight),
                    ),
                  ],
                ),
              ],
            ),
            rowDivider,
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
        ),
        SizedBox(height: 40),
        DropdownMenu(
          initialSelection: model.deviceConfig!.recentHistoryPeriod,
          inputDecorationTheme: InputDecorationThemeData(isDense: true, border: OutlineInputBorder()),
          enableSearch: false,
          requestFocusOnTap: false,
          enableFilter: false,
          label: Text('Period za nedavna mjerenja'),
          onSelected: (int? value) {
            if (value != null) {
              model.updateRecentPeriod(value);
            }
          },
          dropdownMenuEntries: [
            DropdownMenuEntry(value: 30, label: '30 sekundi'),
            DropdownMenuEntry(value: 1 * 60, label: '1 minuta'),
            DropdownMenuEntry(value: 2 * 60, label: '2 minute'),
            DropdownMenuEntry(value: 3 * 60, label: '3 minute'),
            DropdownMenuEntry(value: 5 * 60, label: '5 minuta'),
            DropdownMenuEntry(value: 10 * 60, label: '10 minuta'),
          ],
        ),
      ],
    );
  }

  Widget buildWifiSection(BuildContext context, SettingsPageViewModel model, bool enableButtons) {
    var textTheme = context.textTheme;
    var sectionStyle = textTheme.titleMedium;

    return ExpansionTile(
      leading: FaIcon(FontAwesomeIcons.wifi),
      title: Text('Povezivanje', style: sectionStyle),
      expandedCrossAxisAlignment: CrossAxisAlignment.start,
      expandedAlignment: Alignment.topLeft,
      childrenPadding: EdgeInsets.all(20),
      initiallyExpanded: false,
      children: [
        Text('WiFi mreže', style: textTheme.titleMedium),
        SizedBox(height: 10),
        Column(
          children: model.wifiNetworks.map((e) {
            return ListTile(
              enabled: enableButtons,
              onTap: () {
                showEditNetworkDialog(context, model, e);
              },
              leading: FaIcon(FontAwesomeIcons.wifi),
              title: Text(e.name),
            );
          }).toList(),
        ),
        SizedBox(height: 10),
        OutlinedButton.icon(
          onPressed: () {
            showEditNetworkDialog(context, model, null);
          },
          icon: Icon(Icons.add),
          label: Text('Dodaj'),
        ),
      ],
    );
  }

  Widget buildRtcSection(BuildContext context, SettingsPageViewModel model, bool enableButtons) {
    var textTheme = context.textTheme;
    var sectionStyle = textTheme.titleMedium;
    var keyStyle = textTheme.titleMedium;
    var valueStyle = textTheme.bodyMedium;

    const columnSpacing = SizedBox();
    const rowDivider = TableRow(children: [Divider(), Divider(), Divider()]);

    return ExpansionTile(
      leading: FaIcon(FontAwesomeIcons.clock),
      title: Text('Sat', style: sectionStyle),
      expandedCrossAxisAlignment: CrossAxisAlignment.start,
      expandedAlignment: Alignment.topLeft,
      childrenPadding: EdgeInsets.all(20),
      initiallyExpanded: false,
      children: [
        Table(
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
                Text(Formats.formatDateTime(model.deviceStatus!.rtcTime), style: valueStyle),
              ],
            ),
          ],
        ),
        SizedBox(height: 20),
        OutlinedButton.icon(
          onPressed: enableButtons ? () => model.syncRtcTime() : null,
          icon: FaIcon(FontAwesomeIcons.arrowsRotate),
          label: Text('Sinkroniziraj vrijeme'),
        ),
      ],
    );
  }

  Widget buildAdvancedSection(BuildContext context, SettingsPageViewModel model) {
    var device = model.deviceStatus!;
    var memory = device.memory!;

    var textTheme = context.textTheme;
    var sectionStyle = textTheme.titleMedium;
    var keyStyle = textTheme.titleMedium;
    var valueStyle = textTheme.bodyMedium;

    const columnSpacing = SizedBox();
    const rowDivider = TableRow(children: [Divider(), Divider(), Divider()]);

    return ExpansionTile(
      leading: FaIcon(FontAwesomeIcons.sliders),
      title: Text('Napredno', style: sectionStyle),
      expandedCrossAxisAlignment: CrossAxisAlignment.start,
      expandedAlignment: Alignment.topLeft,
      childrenPadding: EdgeInsets.all(20),
      initiallyExpanded: false,
      children: [
        Table(
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
                    Text(memoryUsageText(memory.usedHeap, memory.heapSize, memory.usedHeapPercent), style: valueStyle),
                    SizedBox(height: 10),

                    ConstrainedBox(
                      constraints: BoxConstraints(maxWidth: lpiMaxWidth),
                      child: LinearProgressIndicator(value: memory.usedHeapPercent, minHeight: lpiHeight),
                    ),
                    SizedBox(height: 10),

                    Text('Max iskorišteno', style: textTheme.titleSmall),
                    Text(
                      memoryUsageText(memory.maxUsedHeap, memory.heapSize, memory.maxUsedHeapPercent),
                      style: valueStyle,
                    ),
                    SizedBox(height: 10),

                    ConstrainedBox(
                      constraints: BoxConstraints(maxWidth: lpiMaxWidth),
                      child: LinearProgressIndicator(value: memory.maxUsedHeapPercent, minHeight: lpiHeight),
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
                    Text(
                      memoryUsageText(memory.usedPsram, memory.psramSize, memory.usedPsramPercent),
                      style: valueStyle,
                    ),
                    SizedBox(height: 10),

                    ConstrainedBox(
                      constraints: BoxConstraints(maxWidth: lpiMaxWidth),
                      child: LinearProgressIndicator(value: memory.usedPsramPercent, minHeight: lpiHeight),
                    ),
                    SizedBox(height: 10),

                    Text('Max iskorišteno', style: textTheme.titleSmall),
                    Text(
                      memoryUsageText(memory.maxUsedPsram, memory.psramSize, memory.maxUsedPsramPercent),
                      style: valueStyle,
                    ),
                    SizedBox(height: 10),

                    ConstrainedBox(
                      constraints: BoxConstraints(maxWidth: lpiMaxWidth),
                      child: LinearProgressIndicator(value: memory.maxUsedPsramPercent, minHeight: lpiHeight),
                    ),
                    SizedBox(height: 10),
                  ],
                ),
              ],
            ),
          ],
        ),
      ],
    );
  }

  void showEditNetworkDialog(BuildContext context, SettingsPageViewModel model, WifiNetwork? network) {
    showDialog(
      context: context,
      fullscreenDialog: true,
      builder: (context) {
        return EditWifiNetworkDialog(model: model, network: network);
      },
    );
  }

  String memoryUsageText(double used, double total, double percent) {
    return '${used.toStringAsFixed(1)} / ${total.toStringAsFixed(1)} KB (${(percent * 100).round()}%)';
  }
}
