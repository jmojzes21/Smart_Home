import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:smart_home_core/device.dart';
import '../../logic/device_service.dart';
import '../../models/exceptions.dart';
import '../../models/smart_leds_device_context.dart';
import '../misc/checkbox.dart';
import '../misc/error_text.dart';

class ChangePasswordDialog extends StatefulWidget {
  const ChangePasswordDialog({super.key});

  @override
  State<ChangePasswordDialog> createState() => _ChangePasswordDialogState();

  static Future<bool> show(BuildContext context) async {
    var result = await showDialog<bool>(context: context, builder: (context) => const ChangePasswordDialog());
    return result ?? false;
  }
}

class _ChangePasswordDialogState extends State<ChangePasswordDialog> {
  var tcOldPassword = TextEditingController();
  var tcNewPassword = TextEditingController();
  var tcConfirmPassword = TextEditingController();

  var showPassword = false;
  var errorMessage = '';

  void changePassword(BuildContext context) async {
    var deviceContext = context.read<DeviceManager>().deviceContext as SmartLedsDeviceContext;
    var device = deviceContext.deviceClient;

    setState(() => errorMessage = '');

    var oldPassword = tcOldPassword.text.trim();
    var newPassword = tcNewPassword.text.trim();
    var confirmPassword = tcConfirmPassword.text.trim();

    if (oldPassword.isEmpty) {
      setState(() => errorMessage = 'Unesite trenutnu lozinku.');
      return;
    }

    if (newPassword.isEmpty) {
      setState(() => errorMessage = 'Unesite novu lozinku.');
      return;
    }

    if (confirmPassword != newPassword) {
      setState(() => errorMessage = 'Potvrda lozinke mora odgovarati novoj lozinki.');
      return;
    }

    var deviceService = DeviceService();

    try {
      await deviceService.changePassword(device: device, plainOldPassword: oldPassword, plainNewPassword: newPassword);
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
      title: const Text('Promjena lozinke'),
      actions: [
        TextButton(
          onPressed: () {
            Navigator.of(context).pop();
          },
          child: const Text('Odustani'),
        ),
        FilledButton(onPressed: () => changePassword(context), child: const Text('Promijeni')),
      ],
      content: Padding(
        padding: const EdgeInsets.symmetric(vertical: 20),
        child: SizedBox(
          width: 300,
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const Text('Trenutna lozinka'),
              const SizedBox(height: 10),
              TextField(
                controller: tcOldPassword,
                obscureText: showPassword == false,
                enableSuggestions: false,
                autocorrect: false,
                decoration: const InputDecoration(isDense: true, border: OutlineInputBorder()),
              ),
              const SizedBox(height: 20),
              const Text('Nova lozinka'),
              const SizedBox(height: 10),
              TextField(
                controller: tcNewPassword,
                obscureText: showPassword == false,
                enableSuggestions: false,
                autocorrect: false,
                decoration: const InputDecoration(isDense: true, border: OutlineInputBorder()),
              ),
              const SizedBox(height: 20),
              const Text('Potvrda lozinke'),
              const SizedBox(height: 10),
              TextField(
                controller: tcConfirmPassword,
                obscureText: showPassword == false,
                enableSuggestions: false,
                autocorrect: false,
                decoration: const InputDecoration(isDense: true, border: OutlineInputBorder()),
              ),
              const SizedBox(height: 20),
              CheckboxText(
                value: showPassword,
                text: 'Prikaži lozinke',
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
    tcOldPassword.dispose();
    tcNewPassword.dispose();
    tcConfirmPassword.dispose();
    super.dispose();
  }
}
