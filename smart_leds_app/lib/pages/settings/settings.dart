import 'package:flutter/material.dart';
import 'package:smart_leds_app/models/device.dart';
import 'package:smart_leds_app/models/device_info.dart';
import 'package:smart_leds_app/models/exceptions.dart';
import 'package:smart_leds_app/widgets/dialogs/change_password.dart';
import 'package:smart_leds_app/theme.dart';
import 'package:smart_leds_app/widgets/message_dialogs.dart';
import 'package:smart_leds_app/widgets/navigation_drawer.dart';
import 'package:smart_leds_app/widgets/update_dialogs.dart';

class SettingsPage extends StatefulWidget {
  const SettingsPage({super.key});
  @override
  State<SettingsPage> createState() => _SettingsPageState();
}

class _SettingsPageState extends State<SettingsPage> {
  DeviceInfo? deviceInfo;

  @override
  void initState() {
    super.initState();
    getDeviceInfo();
  }

  void getDeviceInfo() async {
    var info = await Device.currentDevice.getDeviceInfo();
    setState(() {
      deviceInfo = info;
    });
  }

  void restartDevice() async {
    var result = await showConfirmDialog(context, 'Ponovno pokretanje uređaja',
        'Jeste li sigurni da želite ponovno pokrenuti uređaj?');
    if (result == false) return;

    Device.currentDevice.restart();
  }

  void changePassword() async {
    var result = await ChangePasswordDialog.show(context);
    if (result == null) return;

    try {
      await Device.currentDevice.changePassword(result.$1, result.$2);
    } on DeviceException catch (e) {
      if (!mounted) return;
      showMessageDialog(context, 'Promjena lozinke', e.message);
    }
  }

  void openPrepareUpdateDialog() {
    showDialog(
      context: context,
      barrierDismissible: false,
      builder: (context) {
        return PrepareUpdateWidget();
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Postavke'),
      ),
      drawer: AppNavigationDrawer(),
      body: buildBody(context),
    );
  }

  Widget buildBody(BuildContext context) {
    if (deviceInfo == null) {
      return Center(
        child: SizedBox.square(
          dimension: 100,
          child: CircularProgressIndicator(),
        ),
      );
    }

    var titleStyle = MyTheme.titleMedium;
    var bodyStyle = MyTheme.bodyMedium;
    const spacing = 10.0;

    var content = SizedBox(
      width: MediaQuery.of(context).size.width,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Osnovne informacije
          Text('Osnovne informacije', style: MyTheme.titleLarge),
          SizedBox(height: spacing),
          Text('Naziv', style: titleStyle),
          Text(deviceInfo!.name, style: bodyStyle),
          SizedBox(height: spacing),
          Text('Verzija', style: titleStyle),
          Text(deviceInfo!.firmwareVersion, style: bodyStyle),
          SizedBox(height: spacing),
          Text('WiFi mreža', style: titleStyle),
          Text(deviceInfo!.wifiSSID, style: bodyStyle),
          SizedBox(height: spacing),
          Text('IP adresa', style: titleStyle),
          Text(deviceInfo!.ipAddress, style: bodyStyle),
          SizedBox(height: 2 * spacing),
          ElevatedButton(
            onPressed: () => getDeviceInfo(),
            child: Text('Osvježi'),
          ),
          SizedBox(height: 2 * spacing),

          // WiFi mreže
          Text('WiFi mreže', style: MyTheme.titleLarge),
          SizedBox(height: spacing),
          SizedBox(height: 2 * spacing),

          // OTA update, promjena lozinke
          Text('Ostalo', style: MyTheme.titleLarge),
          SizedBox(height: 2 * spacing),
          ElevatedButton(
            onPressed: () => restartDevice(),
            child: Text('Ponovno pokreni uređaj'),
          ),
          SizedBox(height: 2 * spacing),
          ElevatedButton(
            onPressed: () => changePassword(),
            child: Text('Promijeni lozinku'),
          ),
          SizedBox(height: 2 * spacing),
          ElevatedButton(
            onPressed: () => openPrepareUpdateDialog(),
            child: Text('Ažuriraj ugradbeni program'),
          ),
        ],
      ),
    );

    return SingleChildScrollView(
      child: Padding(
        padding: const EdgeInsets.all(40),
        child: content,
      ),
    );
  }

  @override
  void dispose() {
    super.dispose();
  }
}
