import 'package:flutter/material.dart';
import 'package:smart_leds_app/models/device/device.dart';
import 'package:smart_leds_app/models/exceptions.dart';
import 'package:smart_leds_app/models/wifi_network.dart';
import 'package:smart_leds_app/widgets/dialogs/change_password.dart';
import 'package:smart_leds_app/theme.dart';
import 'package:smart_leds_app/widgets/dialogs/wifi_network.dart';
import 'package:smart_leds_app/widgets/message_dialogs.dart';
import 'package:smart_leds_app/widgets/navigation_drawer.dart';
import 'package:smart_leds_app/widgets/dialogs/update_dialogs.dart';

class SettingsPage extends StatefulWidget {
  const SettingsPage({super.key});
  @override
  State<SettingsPage> createState() => _SettingsPageState();
}

class _SettingsPageState extends State<SettingsPage> {
  late Device device;
  List<WifiNetwork> wifiNetworks = [];

  @override
  void initState() {
    super.initState();
    device = Device.currentDevice;
    getWifiNetworks();
  }

  void getWifiNetworks() async {
    var networks = await Device.currentDevice.getWifiNetworks();
    setState(() {
      wifiNetworks = networks;
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

  void addWifiNetwork() async {
    var network = await WifiNetworkInputDialog.showAddNetwork(context);
    if (network == null) return;

    var networks = [...wifiNetworks];
    networks.add(network);

    Device.currentDevice.updateWifiNetworks(networks);
    getWifiNetworks();
  }

  void openWifiNetwork(WifiNetwork network) async {
    var edited = await WifiNetworkInputDialog.showEditNetwork(context, network);
    if (edited == null) return;

    var networks = [...wifiNetworks];

    if (edited.ssid == '') {
      // obriši mrežu

      networks.removeWhere((e) => e.ssid == network.ssid);
    } else {
      // spremi promjene

      var target = networks.firstWhere((e) => e.ssid == edited.ssid);
      target.password = edited.password;
    }

    Device.currentDevice.updateWifiNetworks(networks);
    getWifiNetworks();
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
          Text(device.name, style: bodyStyle),
          SizedBox(height: spacing),
          Text('Verzija', style: titleStyle),
          Text(device.firmwareVersion, style: bodyStyle),
          SizedBox(height: spacing),
          Text('IP adresa', style: titleStyle),
          Text(device.ipAddress.address, style: bodyStyle),
          SizedBox(height: 2 * spacing),

          // WiFi mreže
          Text('WiFi mreže', style: MyTheme.titleLarge),
          SizedBox(height: spacing),
          ListView.builder(
            itemCount: wifiNetworks.length,
            shrinkWrap: true,
            itemBuilder: (context, index) {
              return ListTile(
                title: Text(wifiNetworks[index].ssid),
                onTap: () => openWifiNetwork(wifiNetworks[index]),
              );
            },
          ),
          SizedBox(height: spacing),
          TextButton(
            onPressed: () => addWifiNetwork(),
            child: Text('Dodaj mrežu'),
          ),
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
