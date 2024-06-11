import 'package:flutter/material.dart';
import 'package:smart_leds_app/logic/device/device.dart';
import 'package:smart_leds_app/logic/device_service.dart';
import 'package:smart_leds_app/models/misc/wifi_network.dart';
import 'package:smart_leds_app/pages/device_discovery.dart';
import 'package:smart_leds_app/widgets/dialogs/change_password.dart';
import 'package:smart_leds_app/theme.dart';
import 'package:smart_leds_app/widgets/dialogs/simple_dialogs.dart';
import 'package:smart_leds_app/widgets/dialogs/firmware_update.dart';
import 'package:smart_leds_app/widgets/dialogs/wifi_network.dart';
import 'package:smart_leds_app/widgets/misc/navigation_drawer.dart';

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
    refresh();
  }

  void refresh() async {
    var infoFuture = device.getDeviceInfo();
    var networksFuture = device.wifi.getNetworks();

    await infoFuture;
    var networks = await networksFuture;

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

    if (result) {
      device.restart();
    }
  }

  void changePassword() async {
    var result = await ChangePasswordDialog.show(context);
    if (result) {
      if (!mounted) return;
      SimpleDialogs.showMessage(
        context: context,
        title: 'Promjena lozinke',
        message: 'Uspješno ste promijenili lozinku.',
      );
    }
  }

  void wipeData() async {
    var result = await SimpleDialogs.showExtraConfirm(
      context: context,
      title: 'Brisanje podataka',
      message: 'Jeste li sigurni da želite obrisati sve podatke s uređaja?',
      checkboxText: 'Potvrda brisanja',
    );

    if (result) {
      await device.wipeData();

      if (!mounted) return;
      await SimpleDialogs.showMessage(
        context: context,
        title: 'Brisanje podataka',
        message: 'Svi podaci su obrisani. Uređaj će se ponovno pokrenuti.',
      );

      var deviceService = DeviceService();
      await deviceService.deleteSession();

      if (!mounted) return;
      Navigator.of(context).pushReplacement(
        MaterialPageRoute(
          builder: (context) => const DeviceDiscoveryPage(),
        ),
      );
    }
  }

  void startDla() async {
    await device.leds.startDla();

    if (!mounted) return;
    SimpleDialogs.showMessage(
      context: context,
      title: 'DLA',
      message: 'DLA je pokrenut.',
    );
  }

  void updateFirmware() async {
    await FirmwareUpdateDialog.show(context);
  }

  void addWifiNetwork() async {
    var result =
        await WifiNetworkInputDialog.showAddNetwork(context, wifiNetworks);

    if (result) {
      refresh();
    }
  }

  void editWifiNetwork(WifiNetwork network) async {
    var result = await WifiNetworkInputDialog.showEditNetwork(
        context, wifiNetworks, network);

    if (result) {
      refresh();
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Postavke'),
      ),
      drawer: const AppNavigationDrawer(),
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
            title: const Text('Osnovne informacije', style: MyTheme.titleLarge),
            expandedCrossAxisAlignment: CrossAxisAlignment.start,
            expandedAlignment: Alignment.topLeft,
            childrenPadding: const EdgeInsets.all(20),
            children: buildDeviceInfoSection(context),
          ),
          ExpansionTile(
            title: const Text('Povezivanje', style: MyTheme.titleLarge),
            expandedCrossAxisAlignment: CrossAxisAlignment.start,
            expandedAlignment: Alignment.topLeft,
            childrenPadding: const EdgeInsets.all(20),
            children: buildConnectivitySection(context),
          ),
          ExpansionTile(
            title: const Text('Sustav', style: MyTheme.titleLarge),
            expandedCrossAxisAlignment: CrossAxisAlignment.start,
            expandedAlignment: Alignment.topLeft,
            childrenPadding: const EdgeInsets.all(20),
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
      const Text('Naziv', style: MyTheme.bodyMediumBold),
      Text(device.name, style: MyTheme.bodyMedium),
      const SizedBox(height: 10),
      const Text('Verzija', style: MyTheme.bodyMediumBold),
      Text(device.firmwareVersion, style: MyTheme.bodyMedium),
      const SizedBox(height: 10),
      const Text('WiFi mreža', style: MyTheme.bodyMediumBold),
      Text(device.wifi.wifiSsid, style: MyTheme.bodyMedium),
      const SizedBox(height: 10),
      const Text('IP adresa', style: MyTheme.bodyMediumBold),
      Text(device.ipAddress.address, style: MyTheme.bodyMedium),
    ];
  }

  List<Widget> buildConnectivitySection(BuildContext context) {
    return [
      const Text('WiFi mreže', style: MyTheme.bodyMediumBold),
      const SizedBox(height: 10),
      ListView.builder(
        itemCount: wifiNetworks.length,
        shrinkWrap: true,
        itemBuilder: (context, index) {
          return ListTile(
            title: Text(wifiNetworks[index].ssid),
            leading: const Icon(Icons.wifi),
            onTap: () => editWifiNetwork(wifiNetworks[index]),
          );
        },
      ),
      const SizedBox(height: 10),
      OutlinedButton.icon(
        onPressed: () => addWifiNetwork(),
        icon: const Icon(Icons.add),
        label: const Text('Dodaj mrežu'),
      ),
    ];
  }

  List<Widget> buildSystemSection(BuildContext context) {
    return [
      const Text('Sigurnost', style: MyTheme.bodyMediumBold),
      const SizedBox(height: 20),
      OutlinedButton.icon(
        onPressed: () => changePassword(),
        icon: const Icon(Icons.lock_outline),
        label: const Text('Promijeni lozinku'),
      ),
      const SizedBox(height: 20),
      OutlinedButton.icon(
        onPressed: () => wipeData(),
        icon: const Icon(Icons.delete_outline),
        label: const Text('Obriši sve podatke'),
      ),
      const SizedBox(height: 40),
      const Text('Uređaj', style: MyTheme.bodyMediumBold),
      const SizedBox(height: 20),
      OutlinedButton.icon(
        onPressed: () => restartDevice(),
        icon: const Icon(Icons.restart_alt),
        label: const Text('Ponovno pokreni uređaj'),
      ),
      const SizedBox(height: 20),
      OutlinedButton.icon(
        onPressed: () => startDla(),
        icon: const Icon(Icons.lightbulb_outline),
        label: const Text('Pokreni DLA'),
      ),
      const SizedBox(height: 20),
      OutlinedButton.icon(
        onPressed: () => updateFirmware(),
        icon: const Icon(Icons.upgrade),
        label: const Text('Ažuriraj ugradbeni program'),
      ),
    ];
  }

  @override
  void dispose() {
    super.dispose();
  }
}
