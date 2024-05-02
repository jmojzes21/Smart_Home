import 'package:flutter/material.dart';
import 'package:smart_leds_app/widgets/misc/checkbox.dart';
import 'package:smart_leds_app/widgets/dialogs/simple_dialogs.dart';

class LoginDialogResult {
  String password = '';
  bool stayLoggedIn = false;

  LoginDialogResult(this.password, this.stayLoggedIn);
}

class LoginDialog extends StatefulWidget {
  const LoginDialog({super.key});

  @override
  State<LoginDialog> createState() => _LoginDialogState();

  static Future<LoginDialogResult?> show(BuildContext context) async {
    var result = await showDialog<LoginDialogResult>(
      context: context,
      builder: (context) => LoginDialog(),
    );

    return result;
  }
}

class _LoginDialogState extends State<LoginDialog> {
  var tcPassword = TextEditingController();
  var showPassword = false;
  var stayLoggedIn = false;

  void login() {
    var password = tcPassword.text.trim();
    if (password.isEmpty) {
      SimpleDialogs.showMessage(
          context: context,
          title: 'Prijava',
          message: 'Potrebno je unijeti lozinku.');
      return;
    }

    var result = LoginDialogResult(password, stayLoggedIn);
    Navigator.of(context).pop(result);
  }

  @override
  Widget build(BuildContext context) {
    return AlertDialog(
      title: Text('Prijava'),
      actions: [
        TextButton(
          onPressed: () => Navigator.of(context).pop(),
          child: Text('Odustani'),
        ),
        FilledButton(
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
                obscureText: showPassword == false,
                enableSuggestions: false,
                autocorrect: false,
                decoration: InputDecoration(
                  isDense: true,
                  border: OutlineInputBorder(),
                ),
              ),
              const SizedBox(height: 10),
              CheckboxText(
                value: showPassword,
                text: 'Prikaži lozinku',
                onChanged: (value) => setState(() => showPassword = value),
              ),
              const SizedBox(height: 5),
              CheckboxText(
                value: stayLoggedIn,
                text: 'Ostani prijavljen',
                onChanged: (value) => setState(() => stayLoggedIn = value),
              ),
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
