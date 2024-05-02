import 'package:flutter/material.dart';
import 'package:smart_leds_app/widgets/misc/checkbox.dart';

class ChangePasswordDialog extends StatefulWidget {
  const ChangePasswordDialog({super.key});

  @override
  State<ChangePasswordDialog> createState() => _ChangePasswordDialogState();

  static Future<(String oldPass, String newPass)?> show(
      BuildContext context) async {
    var result = await showDialog<(String, String)>(
      context: context,
      builder: (context) => ChangePasswordDialog(),
    );

    return result;
  }
}

class _ChangePasswordDialogState extends State<ChangePasswordDialog> {
  var tcOldPassword = TextEditingController();
  var tcNewPassword = TextEditingController();
  var tcConfirmPassword = TextEditingController();
  var showPassword = false;

  void changePassword() {
    var oldPassword = tcOldPassword.text.trim();
    var newPassword = tcNewPassword.text.trim();
    var confirmPassword = tcConfirmPassword.text.trim();

    if (oldPassword.isEmpty || newPassword.isEmpty || confirmPassword.isEmpty) {
      return;
    }
    if (newPassword != confirmPassword) return;

    Navigator.of(context).pop((oldPassword, newPassword));
  }

  @override
  Widget build(BuildContext context) {
    return AlertDialog(
      title: Text('Promjena lozinke'),
      actions: [
        TextButton(
          onPressed: () {
            Navigator.of(context).pop();
          },
          child: Text('Odustani'),
        ),
        FilledButton(
          onPressed: () => changePassword(),
          child: Text('Promijeni lozinku'),
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
              Text('Trenutna lozinka'),
              const SizedBox(height: 10),
              TextField(
                controller: tcOldPassword,
                obscureText: showPassword == false,
                enableSuggestions: false,
                autocorrect: false,
                decoration: InputDecoration(
                  isDense: true,
                  border: OutlineInputBorder(),
                ),
              ),
              const SizedBox(height: 20),
              Text('Nova lozinka'),
              const SizedBox(height: 10),
              TextField(
                controller: tcNewPassword,
                obscureText: showPassword == false,
                enableSuggestions: false,
                autocorrect: false,
                decoration: InputDecoration(
                  isDense: true,
                  border: OutlineInputBorder(),
                ),
              ),
              const SizedBox(height: 20),
              Text('Potvrda lozinke'),
              const SizedBox(height: 10),
              TextField(
                controller: tcConfirmPassword,
                obscureText: showPassword == false,
                enableSuggestions: false,
                autocorrect: false,
                decoration: InputDecoration(
                  isDense: true,
                  border: OutlineInputBorder(),
                ),
              ),
              const SizedBox(height: 20),
              CheckboxText(
                value: showPassword,
                text: 'Prikaži lozinke',
                onChanged: (value) => setState(() => showPassword = value),
              ),
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
