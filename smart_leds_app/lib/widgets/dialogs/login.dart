import 'package:flutter/material.dart';
import 'package:smart_leds_app/models/device.dart';
import 'package:smart_leds_app/models/exceptions.dart';
import 'package:smart_leds_app/widgets/message_dialogs.dart';

class LoginDialog extends StatefulWidget {
  final Device device;
  const LoginDialog({super.key, required this.device});

  @override
  State<LoginDialog> createState() => _LoginDialogState();
}

class _LoginDialogState extends State<LoginDialog> {
  var tcPassword = TextEditingController();

  void login() async {
    try {
      var password = tcPassword.text.trim();
      if (password.isEmpty) return;

      await widget.device.login(password);

      if (!mounted) return;
      Navigator.of(context).pop();
    } on DeviceException catch (e) {
      if (!mounted) return;
      showMessageDialog(context, 'Prijava', e.message);
    }
  }

  @override
  Widget build(BuildContext context) {
    return AlertDialog(
      title: Text('Prijava'),
      actions: [
        TextButton(
          onPressed: () {
            Navigator.of(context).pop();
          },
          child: Text('Odustani'),
        ),
        TextButton(
          onPressed: () => login(),
          child: Text('Prijavi se'),
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
              Text('Lozinka'),
              const SizedBox(height: 10),
              TextField(
                controller: tcPassword,
                obscureText: true,
                enableSuggestions: false,
                autocorrect: false,
                decoration: InputDecoration(
                  isDense: true,
                  border: OutlineInputBorder(),
                ),
              )
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
