import 'dart:async';
import 'dart:developer';
import 'dart:io';

import 'package:async/async.dart';
import 'package:flutter/material.dart';
import '../../logic/device/device.dart';
import '../../models/exceptions.dart';
import '../misc/error_text.dart';

class DirectConnectionDialog extends StatefulWidget {
  const DirectConnectionDialog({super.key});

  @override
  State<DirectConnectionDialog> createState() => _DirectConnectionDialogState();

  static Future<Device?> show(BuildContext context) async {
    var result = await showDialog<Device>(context: context, barrierDismissible: false, builder: (context) => const DirectConnectionDialog());

    return result;
  }
}

class _DirectConnectionDialogState extends State<DirectConnectionDialog> {
  var tcIpAddress = TextEditingController();
  var isConnecting = false;
  var errorMessage = '';

  CancelableOperation<bool>? connectOperation;

  void connect() async {
    if (isConnecting) return;

    setError('');

    var ipAddress = InternetAddress.tryParse(tcIpAddress.text.trim());

    if (ipAddress == null) {
      setError('IP adresa nije u valjanom obliku.');
      return;
    }

    var device = Device(ipAddress: ipAddress);

    setState(() => isConnecting = true);

    connectOperation = CancelableOperation.fromFuture(connectFuture(device));
    connectOperation!.then((bool result) => onConnectDone(device, result), onCancel: () => onConnectCancel());
  }

  void onConnectDone(Device device, bool result) {
    if (result) {
      log('Izravno povezivanje uspjelo');

      if (!mounted) return;
      Navigator.of(context).pop(device);
    } else {
      log('Izravno povezivanje nije uspjelo');

      if (!mounted) return;
      setState(() {
        isConnecting = false;
        errorMessage = 'Povezivanje na uređaj nije uspjelo.';
      });
    }
  }

  void onConnectCancel() {
    log('Izravno povezivanje prekinuto');
    if (!mounted) return;
    setState(() => isConnecting = false);
    connectOperation = null;
  }

  Future<bool> connectFuture(Device device) async {
    log('Izravno povezivanje na uređaj ${device.ipAddress.address}');
    try {
      await device.getDeviceInfo();
      return true;
    } on DeviceException catch (_) {
      return false;
    }
  }

  void stop() async {
    connectOperation?.cancel();
  }

  void close() async {
    stop();
    Navigator.of(context).pop();
  }

  void setError(String message) {
    if (!mounted) return;
    setState(() => errorMessage = message);
  }

  @override
  Widget build(BuildContext context) {
    return AlertDialog(
      title: const Text('Izravno povezivanje'),
      actions: [
        TextButton(onPressed: () => close(), child: const Text('Odustani')),
        if (isConnecting) FilledButton(onPressed: () => stop(), child: const Text('Zaustavi')),
        if (isConnecting == false) FilledButton(onPressed: () => connect(), child: const Text('Poveži')),
      ],
      content: Padding(
        padding: const EdgeInsets.symmetric(vertical: 20),
        child: SizedBox(
          width: 300,
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const Text('IP adresa'),
              const SizedBox(height: 10),
              TextField(
                controller: tcIpAddress,
                enableSuggestions: false,
                autocorrect: false,
                decoration: const InputDecoration(isDense: true, border: OutlineInputBorder()),
              ),
              if (isConnecting) const SizedBox(height: 20),
              if (isConnecting)
                const Row(
                  children: [
                    SizedBox.square(dimension: 24, child: CircularProgressIndicator()),
                    SizedBox(width: 10),
                    Text('Povezivanje'),
                  ],
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
    tcIpAddress.dispose();
    super.dispose();
  }
}
