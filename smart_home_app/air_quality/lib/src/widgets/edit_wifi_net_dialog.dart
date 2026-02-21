import 'package:flutter/material.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';
import 'package:go_router/go_router.dart';
import 'package:smart_home_core/widgets.dart';

import '../logic/vm/settings_page_vm.dart';
import '../models/device_config.dart';

class EditWifiNetworkDialog extends StatefulWidget {
  final SettingsPageViewModel model;
  final WifiNetwork? network;

  const EditWifiNetworkDialog({super.key, required this.model, required this.network});

  @override
  State<EditWifiNetworkDialog> createState() => _EditWifiNetworkDialogState();
}

class _EditWifiNetworkDialogState extends State<EditWifiNetworkDialog> {
  final tecName = TextEditingController();
  final tecPassword = TextEditingController();
  bool showPassword = false;

  late SettingsPageViewModel model;
  late bool isEditMode;

  @override
  void initState() {
    super.initState();
    model = widget.model;
    var network = widget.network ?? WifiNetwork(name: '', password: '');

    isEditMode = widget.network != null;

    tecName.text = network.name;
    tecPassword.text = network.password;
  }

  void setShowPassword(bool show) {
    setState(() {
      showPassword = show;
    });
  }

  WifiNetwork getNetwork() {
    String name = tecName.text.trim();
    String password = tecPassword.text.trim();
    return WifiNetwork(name: name, password: password);
  }

  @override
  Widget build(BuildContext context) {
    return Dialog.fullscreen(
      child: Scaffold(
        appBar: AppBar(title: Text('WiFi mreža')),
        body: SingleChildScrollView(
          child: Padding(
            padding: EdgeInsets.all(20),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                TextField(
                  controller: tecName,
                  readOnly: isEditMode,
                  textInputAction: TextInputAction.next,
                  decoration: InputDecoration(label: Text('Naziv'), isDense: true, border: OutlineInputBorder()),
                ),
                SizedBox(height: 20),
                TextField(
                  controller: tecPassword,
                  obscureText: !showPassword,
                  textInputAction: TextInputAction.done,
                  decoration: InputDecoration(
                    label: Text('Lozinka'),
                    isDense: true,
                    border: OutlineInputBorder(),
                    suffixIcon: IconButton(
                      onPressed: () => setShowPassword(!showPassword),
                      icon: !showPassword ? FaIcon(FontAwesomeIcons.solidEye) : FaIcon(FontAwesomeIcons.solidEyeSlash),
                    ),
                  ),
                ),
                SizedBox(height: 40),
                Row(
                  spacing: 20,
                  children: [
                    if (isEditMode)
                      FilledButton(
                        onPressed: () {
                          model.updateNetwork(getNetwork(), () => context.pop());
                        },
                        child: Text('Spremi'),
                      ),

                    if (!isEditMode)
                      FilledButton(
                        onPressed: () {
                          model.addNetwork(getNetwork(), () => context.pop());
                        },
                        child: Text('Dodaj'),
                      ),

                    TextButton(onPressed: () => context.pop(), child: Text('Odustani')),
                  ],
                ),

                if (isEditMode) SizedBox(height: 20),
                if (isEditMode)
                  TextButton(
                    onPressed: () async {
                      bool result = await Dialogs.showConfirmDialog(
                        context,
                        'Jeste li sigurni da želite obrisati WiFi mrežu?',
                      );
                      if (!result || !context.mounted) return;

                      model.deleteNetwork(getNetwork(), () => context.pop());
                    },
                    child: Text('Obriši'),
                  ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  @override
  void dispose() {
    tecName.dispose();
    tecPassword.dispose();
    super.dispose();
  }
}
