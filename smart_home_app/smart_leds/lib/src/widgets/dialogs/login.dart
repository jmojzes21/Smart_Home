import 'package:flutter/material.dart';
import '../../logic/device/device.dart';
import '../../logic/device_service.dart';
import '../../models/exceptions.dart';
import 'simple_dialogs.dart';
import '../misc/checkbox.dart';
import '../misc/error_text.dart';

class LoginDialog extends StatefulWidget {
  final Device device;
  const LoginDialog(this.device, {super.key});

  @override
  State<LoginDialog> createState() => _LoginDialogState();

  static Future<bool> show(BuildContext context, Device device) async {
    var result = await showDialog<bool>(context: context, builder: (context) => LoginDialog(device));

    return result ?? false;
  }
}

class _LoginDialogState extends State<LoginDialog> {
  var tcPassword = TextEditingController();
  var showPassword = false;
  var stayLoggedIn = false;
  var errorMessage = '';

  void login() async {
    var password = tcPassword.text.trim();

    if (password.isEmpty) {
      setError('Unesite lozinku.');
      return;
    }

    var device = widget.device;
    var deviceService = DeviceService();

    try {
      await deviceService.login(device: device, plainPassword: password, stayLoggedIn: stayLoggedIn);
    } on DeviceException catch (e) {
      setError(e.message);
      return;
    }

    if (!mounted) return;
    Navigator.of(context).pop(true);
  }

  void setError(String message) {
    if (!mounted) return;
    setState(() => errorMessage = message);
  }

  void resetPassword() async {
    var result = await SimpleDialogs.showExtraConfirm(
      context: context,
      title: 'Zaboravljena lozinka',
      message:
          'Ukoliko ste zaboravili lozinku, uređaj možete ponovno postaviti. Tako će se spremljeni podaci '
          'obrisati, a lozinka će se vratiti na zadanu vrijednost. Želite li nastaviti?',
      checkboxText: 'Potvrda ponovnog postavljanja uređaja',
    );

    if (result) {
      var device = widget.device;
      await device.wipeData();

      if (!mounted) return;
      await SimpleDialogs.showMessage(context: context, title: 'Ponovno postavljanje uređaja', message: 'Uređaj se ponovno postavio i svi prijašnji podaci su obrisani.');

      if (!mounted) return;
      Navigator.of(context).pop();
    }
  }

  @override
  Widget build(BuildContext context) {
    return AlertDialog(
      title: const Text('Prijava'),
      actions: [
        TextButton(onPressed: () => Navigator.of(context).pop(), child: const Text('Odustani')),
        FilledButton(onPressed: () => login(), child: const Text('Prijavi se')),
      ],
      content: Padding(
        padding: const EdgeInsets.symmetric(vertical: 20),
        child: SizedBox(
          width: 300,
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const Text('Lozinka'),
              const SizedBox(height: 10),
              TextField(
                controller: tcPassword,
                obscureText: showPassword == false,
                enableSuggestions: false,
                autocorrect: false,
                decoration: const InputDecoration(isDense: true, border: OutlineInputBorder()),
              ),
              const SizedBox(height: 10),
              CheckboxText(value: showPassword, text: 'Prikaži lozinku', onChanged: (value) => setState(() => showPassword = value)),
              const SizedBox(height: 5),
              CheckboxText(value: stayLoggedIn, text: 'Ostani prijavljen', onChanged: (value) => setState(() => stayLoggedIn = value)),
              const SizedBox(height: 5),
              TextButton(onPressed: () => resetPassword(), child: const Text('Zaboravljena lozinka')),
              if (errorMessage.isNotEmpty) ErrorText(errorMessage),
            ],
          ),
        ),
      ),
    );
  }

  @override
  void dispose() {
    tcPassword.dispose();
    super.dispose();
  }
}
