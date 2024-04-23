import 'package:flutter/material.dart';
import 'package:smart_leds_app/models/wifi_network.dart';
import 'package:smart_leds_app/widgets/dialogs/simple_dialogs.dart';

class WifiNetworkInputDialog extends StatefulWidget {
  final WifiNetwork? wifiNetwork;
  const WifiNetworkInputDialog(this.wifiNetwork, {super.key});

  @override
  State<WifiNetworkInputDialog> createState() => _WifiNetworkInputDialogState();

  static Future<WifiNetwork?> showAddNetwork(BuildContext context) async {
    return _show(context, null);
  }

  static Future<WifiNetwork?> showEditNetwork(
      BuildContext context, WifiNetwork network) async {
    return _show(context, network);
  }

  static Future<WifiNetwork?> _show(
      BuildContext context, WifiNetwork? network) async {
    var result = await showDialog<WifiNetwork>(
      context: context,
      builder: (context) => WifiNetworkInputDialog(network),
    );

    return result;
  }
}

class _WifiNetworkInputDialogState extends State<WifiNetworkInputDialog> {
  var tcName = TextEditingController();
  var tcPassword = TextEditingController();
  bool editMode = false;
  bool showPassword = false;

  @override
  void initState() {
    super.initState();

    editMode = widget.wifiNetwork != null;
    if (editMode) {
      tcName.text = widget.wifiNetwork!.ssid;
      tcPassword.text = widget.wifiNetwork!.password;
    }
  }

  void addOrSave() {
    String name = tcName.text.trim();
    String pass = tcPassword.text.trim();

    if (name.isEmpty) {
      SimpleDialogs.showMessage(
        context: context,
        title: 'Dodavanje WiFi mreže',
        message: 'Potrebno je unijeti naziv WiFi mreže.',
      );
      return;
    }

    var network = WifiNetwork(name, pass);
    Navigator.of(context).pop(network);
  }

  void delete() async {
    var result = await SimpleDialogs.showConfirm(
      context: context,
      title: 'Brisanje WiFi mreže',
      message: 'Jeste li sigurni da želite obrisati WiFi mrežu?',
    );

    if (result == false) return;
    if (!mounted) return;

    var network = WifiNetwork('', '');
    Navigator.of(context).pop(network);
  }

  @override
  Widget build(BuildContext context) {
    return AlertDialog(
      title: Text(editMode ? 'Uredi WiFi mrežu' : 'Dodaj WiFi mrežu'),
      actions: [
        TextButton(
          onPressed: () {
            Navigator.of(context).pop();
          },
          child: Text('Odustani'),
        ),
        if (editMode)
          TextButton(
            onPressed: () => delete(),
            child: Text('Obriši'),
          ),
        TextButton(
          onPressed: () => addOrSave(),
          child: Text(editMode ? 'Spremi' : 'Dodaj'),
        ),
      ],
      content: Padding(
        padding: const EdgeInsets.symmetric(vertical: 20),
        child: SizedBox(
          width: 300,
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text('Naziv'),
              const SizedBox(height: 10),
              TextField(
                controller: tcName,
                readOnly: editMode,
                enableSuggestions: false,
                autocorrect: false,
                decoration: InputDecoration(
                  isDense: true,
                  border: OutlineInputBorder(),
                ),
              ),
              const SizedBox(height: 20),
              Text('Lozinka'),
              const SizedBox(height: 10),
              TextField(
                controller: tcPassword,
                obscureText: showPassword == false,
                enableSuggestions: false,
                autocorrect: false,
                decoration: InputDecoration(
                  isDense: true,
                  border: OutlineInputBorder(),
                ),
              ),
              SizedBox(height: 5),
              Row(
                children: [
                  Checkbox(
                    value: showPassword,
                    onChanged: (bool? value) {
                      setState(() {
                        showPassword = value ?? false;
                      });
                    },
                  ),
                  Text('Prikaži lozinku'),
                ],
              ),
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
