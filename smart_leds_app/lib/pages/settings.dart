import 'package:flutter/material.dart';
import 'package:smart_leds_app/logic/device/device.dart';
import 'package:smart_leds_app/models/exceptions.dart';
import 'package:smart_leds_app/models/misc/wifi_network.dart';
import 'package:smart_leds_app/widgets/dialogs/change_password.dart';
import 'package:smart_leds_app/theme.dart';
import 'package:smart_leds_app/widgets/dialogs/simple_dialogs.dart';
import 'package:smart_leds_app/widgets/dialogs/wifi_network.dart';
import 'package:smart_leds_app/widgets/misc/navigation_drawer.dart';
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
    var networks = await Device.currentDevice.wifi.getNetworks();
    setState(() {
      wifiNetworks = networks;
    });
  }

  void restartDevice() async {
    var result = await SimpleDialogs.showConfirm(
      context: context,
      title: 'Ponovno pokretanje uređaja',
      message: 'Jeste li sigurni da želite ponovno pokrenuti uređaj?',
    );

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

      SimpleDialogs.showMessage(
        context: context,
        title: 'Promjena lozinke',
        message: e.message,
      );
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

    Device.currentDevice.wifi.updateNetworks(networks);
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

    Device.currentDevice.wifi.updateNetworks(networks);
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
    var content = SizedBox(
      width: MediaQuery.of(context).size.width,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          ExpansionTile(
            title: Text('Osnovne informacije', style: MyTheme.titleLarge),
            expandedCrossAxisAlignment: CrossAxisAlignment.start,
            expandedAlignment: Alignment.topLeft,
            childrenPadding: EdgeInsets.all(20),
            children: buildDeviceInfoSection(context),
          ),
          ExpansionTile(
            title: Text('Povezivanje', style: MyTheme.titleLarge),
            expandedCrossAxisAlignment: CrossAxisAlignment.start,
            expandedAlignment: Alignment.topLeft,
            childrenPadding: EdgeInsets.all(20),
            children: buildConnectivitySection(context),
          ),
          ExpansionTile(
            title: Text('Sustav', style: MyTheme.titleLarge),
            expandedCrossAxisAlignment: CrossAxisAlignment.start,
            expandedAlignment: Alignment.topLeft,
            childrenPadding: EdgeInsets.all(20),
            children: buildSystemSection(context),
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

  List<Widget> buildDeviceInfoSection(BuildContext context) {
    return [
      Text('Naziv', style: MyTheme.bodyMediumBold),
      Text(device.name, style: MyTheme.bodyMedium),
      SizedBox(height: 10),
      Text('Verzija', style: MyTheme.bodyMediumBold),
      Text(device.firmwareVersion, style: MyTheme.bodyMedium),
      SizedBox(height: 10),
      Text('IP adresa', style: MyTheme.bodyMediumBold),
      Text(device.ipAddress.address, style: MyTheme.bodyMedium),
    ];
  }

  List<Widget> buildConnectivitySection(BuildContext context) {
    return [
      Text('WiFi mreže', style: MyTheme.bodyMediumBold),
      SizedBox(height: 10),
      ListView.builder(
        itemCount: wifiNetworks.length,
        shrinkWrap: true,
        itemBuilder: (context, index) {
          return ListTile(
            title: Text(wifiNetworks[index].ssid),
            leading: Icon(Icons.wifi),
            onTap: () => openWifiNetwork(wifiNetworks[index]),
          );
        },
      ),
      SizedBox(height: 10),
      OutlinedButton.icon(
        onPressed: () => addWifiNetwork(),
        icon: Icon(Icons.add),
        label: Text('Dodaj mrežu'),
      ),
    ];
  }

  List<Widget> buildSystemSection(BuildContext context) {
    return [
      Text('Sigurnost', style: MyTheme.bodyMediumBold),
      SizedBox(height: 20),
      OutlinedButton.icon(
        onPressed: () => changePassword(),
        icon: Icon(Icons.lock_outline),
        label: Text('Promijeni lozinku'),
      ),
      SizedBox(height: 20),
      OutlinedButton.icon(
        onPressed: () {},
        icon: Icon(Icons.delete_outline),
        label: Text('Obriši sve podatke'),
      ),
      SizedBox(height: 40),
      Text('Uređaj', style: MyTheme.bodyMediumBold),
      SizedBox(height: 20),
      OutlinedButton.icon(
        onPressed: () => restartDevice(),
        icon: Icon(Icons.restart_alt),
        label: Text('Ponovno pokreni uređaj'),
      ),
      SizedBox(height: 20),
      OutlinedButton.icon(
        onPressed: () => openPrepareUpdateDialog(),
        icon: Icon(Icons.upgrade),
        label: Text('Ažuriraj ugradbeni program'),
      ),
    ];
  }

  @override
  void dispose() {
    super.dispose();
  }
}
