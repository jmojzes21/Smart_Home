import 'dart:io';

import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';

class IpAddressDialog extends StatefulWidget {
  const IpAddressDialog({super.key});

  @override
  State<IpAddressDialog> createState() => _IpAddressDialogState();

  static Future<InternetAddress?> open(BuildContext context) async {
    return showDialog(context: context, barrierDismissible: false, builder: (context) => IpAddressDialog());
  }
}

class _IpAddressDialogState extends State<IpAddressDialog> {
  final tecAddress = TextEditingController();
  String? message;

  void onConnect() {
    var addressText = tecAddress.text.trim();

    if (addressText.isEmpty) {
      setState(() => message = 'Unesite IP adresu');
      return;
    }

    InternetAddress? ipAddress = InternetAddress.tryParse(addressText);
    if (ipAddress == null) {
      setState(() => message = "Unesite valjanu IP adresu");
      return;
    }

    context.pop(ipAddress);
  }

  @override
  Widget build(BuildContext context) {
    return AlertDialog(
      title: Text('Izravno povezivanje'),
      contentPadding: EdgeInsets.all(20),
      content: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          SizedBox(
            width: 300,
            child: TextField(
              controller: tecAddress,
              decoration: InputDecoration(
                isDense: true,
                label: Text('IP adresa'),
                error: message != null ? Text(message!) : null,
                border: OutlineInputBorder(),
              ),
            ),
          ),
          SizedBox(height: 20),
        ],
      ),
      actions: [
        TextButton(onPressed: () => context.pop(), child: Text('Odustani')),
        FilledButton(onPressed: () => onConnect(), child: Text('Poveži se')),
      ],
    );
  }

  @override
  void dispose() {
    tecAddress.dispose();
    super.dispose();
  }
}
