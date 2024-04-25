import 'package:flutter/material.dart';

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
        TextButton(
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
                obscureText: true,
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
                obscureText: true,
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
                obscureText: true,
                enableSuggestions: false,
                autocorrect: false,
                decoration: InputDecoration(
                  isDense: true,
                  border: OutlineInputBorder(),
                ),
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
