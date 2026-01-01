import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:smart_home_core/device.dart';
import '../../models/exceptions.dart';
import '../../models/misc/wifi_network.dart';
import '../../models/smart_leds_device_context.dart';
import 'simple_dialogs.dart';
import '../misc/checkbox.dart';
import '../misc/error_text.dart';

class WifiNetworkInputDialog extends StatefulWidget {
  final List<WifiNetwork> networks;
  final WifiNetwork? network;
  const WifiNetworkInputDialog(this.networks, this.network, {super.key});

  @override
  State<WifiNetworkInputDialog> createState() => _WifiNetworkInputDialogState();

  static Future<bool> showAddNetwork(BuildContext context, List<WifiNetwork> networks) async {
    return _show(context, networks, null);
  }

  static Future<bool> showEditNetwork(BuildContext context, List<WifiNetwork> networks, WifiNetwork network) async {
    return _show(context, networks, network);
  }

  static Future<bool> _show(BuildContext context, List<WifiNetwork> networks, WifiNetwork? network) async {
    var result = await showDialog<bool>(
      context: context,
      builder: (context) => WifiNetworkInputDialog(networks, network),
    );

    return result ?? false;
  }
}

class _WifiNetworkInputDialogState extends State<WifiNetworkInputDialog> {
  late List<WifiNetwork> networks;
  String ssid = '';

  var tcName = TextEditingController();
  var tcPassword = TextEditingController();

  String errorMessage = '';
  bool editMode = false;
  bool showPassword = false;

  @override
  void initState() {
    super.initState();

    networks = widget.networks.map((e) => e.copy()).toList();

    if (widget.network != null) {
      ssid = widget.network!.ssid;
      tcName.text = widget.network!.ssid;
      tcPassword.text = widget.network!.password;
      editMode = true;
    }
  }

  void add(BuildContext context) async {
    var deviceContext = context.read<DeviceManager>().deviceContext as SmartLedsDeviceContext;
    var device = deviceContext.deviceClient;

    String name = tcName.text.trim();
    String pass = tcPassword.text.trim();

    if (name.isEmpty) {
      setState(() => errorMessage = 'Postavite naziv WiFi mreže.');
      return;
    }

    var network = WifiNetwork(name, pass);
    networks.add(network);

    try {
      await device.wifi.updateNetworks(networks);
    } on DeviceException catch (e) {
      if (!mounted) return;
      setState(() => errorMessage = e.message);
      return;
    }

    if (!context.mounted) return;
    Navigator.of(context).pop(true);
  }

  void save(BuildContext context) async {
    var deviceContext = context.read<DeviceManager>().deviceContext as SmartLedsDeviceContext;
    var device = deviceContext.deviceClient;

    String pass = tcPassword.text.trim();

    var network = networks.firstWhere((e) => e.ssid == ssid);
    network.password = pass;

    try {
      await device.wifi.updateNetworks(networks);
    } on DeviceException catch (e) {
      if (!mounted) return;
      setState(() => errorMessage = e.message);
      return;
    }

    if (!context.mounted) return;
    Navigator.of(context).pop(true);
  }

  void addOrSave(BuildContext context) {
    setState(() => errorMessage = '');

    if (editMode) {
      save(context);
    } else {
      add(context);
    }
  }

  void delete(BuildContext context) async {
    var deviceContext = context.read<DeviceManager>().deviceContext as SmartLedsDeviceContext;
    var device = deviceContext.deviceClient;

    var result = await SimpleDialogs.showConfirm(
      context: context,
      title: 'Brisanje WiFi mreže',
      message: 'Jeste li sigurni da želite obrisati WiFi mrežu?',
    );

    if (result == false) return;
    if (!mounted) return;

    networks.removeWhere((e) => e.ssid == ssid);

    try {
      await device.wifi.updateNetworks(networks);
    } on DeviceException catch (e) {
      if (!mounted) return;
      setState(() => errorMessage = e.message);
      return;
    }

    if (!context.mounted) return;
    Navigator.of(context).pop(true);
  }

  @override
  Widget build(BuildContext context) {
    return AlertDialog(
      title: Text(editMode ? 'Uredi WiFi mrežu' : 'Dodaj WiFi mrežu'),
      actions: [
        if (editMode) TextButton(onPressed: () => delete(context), child: const Text('Obriši')),
        TextButton(
          onPressed: () {
            Navigator.of(context).pop();
          },
          child: const Text('Odustani'),
        ),
        FilledButton(onPressed: () => addOrSave(context), child: Text(editMode ? 'Spremi' : 'Dodaj')),
      ],
      content: Padding(
        padding: const EdgeInsets.symmetric(vertical: 20),
        child: SizedBox(
          width: 300,
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const Text('Naziv'),
              const SizedBox(height: 10),
              TextField(
                controller: tcName,
                readOnly: editMode,
                enableSuggestions: false,
                autocorrect: false,
                decoration: const InputDecoration(isDense: true, border: OutlineInputBorder()),
              ),
              const SizedBox(height: 20),
              const Text('Lozinka'),
              const SizedBox(height: 10),
              TextField(
                controller: tcPassword,
                obscureText: showPassword == false,
                enableSuggestions: false,
                autocorrect: false,
                decoration: const InputDecoration(isDense: true, border: OutlineInputBorder()),
              ),
              const SizedBox(height: 5),
              CheckboxText(
                value: showPassword,
                text: 'Prikaži lozinku',
                onChanged: (value) => setState(() => showPassword = value),
              ),
              if (errorMessage.isNotEmpty) ErrorText(errorMessage),
            ],
          ),
        ),
      ),
    );
  }

  @override
  void dispose() {
    tcName.dispose();
    tcPassword.dispose();
    super.dispose();
  }
}
