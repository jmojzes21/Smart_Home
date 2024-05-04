import 'dart:io';

import 'package:flutter/material.dart';
import 'package:smart_leds_app/logic/device/device.dart';
import 'package:smart_leds_app/logic/device_discovery.dart';
import 'package:smart_leds_app/logic/device_service.dart';
import 'package:smart_leds_app/widgets/dialogs/direct_connection.dart';
import 'package:smart_leds_app/widgets/dialogs/login.dart';
import 'package:smart_leds_app/pages/home.dart';
import 'package:smart_leds_app/widgets/dialogs/simple_dialogs.dart';

class DeviceDiscoveryPage extends StatefulWidget {
  const DeviceDiscoveryPage({super.key});
  @override
  State<DeviceDiscoveryPage> createState() => _DeviceDiscoveryPageState();
}

class _DeviceDiscoveryPageState extends State<DeviceDiscoveryPage> {
  var deviceDiscovery = DeviceDiscovery();
  var discoveredDevices = <Device>[];
  var isDiscovering = false;
  var showTestDevice = true;

  @override
  void initState() {
    super.initState();
    loadSession();
  }

  void startScan() async {
    try {
      await _startScan();
    } on Exception catch (_) {
      if (!mounted) return;

      SimpleDialogs.showMessage(
        context: context,
        title: 'Pretraživanje uređaja',
        message: 'Greška prilikom pretraživanja uređaja!',
      );
    }
  }

  Future<void> _startScan() async {
    setState(() {
      isDiscovering = true;
      discoveredDevices.clear();

      if (showTestDevice) {
        discoveredDevices.add(Device(
          name: 'Testni uređaj',
          ipAddress: InternetAddress('127.0.0.1'),
        ));
      }
    });

    await deviceDiscovery.start().forEach((device) {
      if (mounted == false) return;
      setState(() {
        discoveredDevices.add(device);
      });
    });

    if (mounted == false) return;

    setState(() {
      isDiscovering = false;
    });
  }

  void stopScan() {
    deviceDiscovery.stop();
  }

  Future<void> connectDevice(Device device) async {
    bool ok = await LoginDialog.show(context, device);
    if (ok) {
      openHomePage(device);
    }
  }

  Future<void> connectDirectly() async {
    Device? device = await DirectConnectionDialog.show(context);
    if (device != null) {
      await connectDevice(device);
    }
  }

  Future<void> loadSession() async {
    var deviceService = DeviceService();
    Device? device = await deviceService.restoreSession();

    if (device != null) {
      if (!mounted) return;
      openHomePage(device);
    }
  }

  void openHomePage(Device device) {
    Device.currentDevice = device;

    Navigator.of(context).pushReplacement(
      MaterialPageRoute(builder: (context) => HomePage()),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Center(
        child: Card(
          child: SizedBox(
            width: 500,
            height: 400,
            child: Padding(
              padding: const EdgeInsets.all(20),
              child: Column(
                children: [
                  ListTile(
                    title: Text(
                      'Pretraživanje uređaja',
                      style: Theme.of(context).textTheme.titleLarge,
                    ),
                    trailing: isDiscovering
                        ? const CircularProgressIndicator()
                        : null,
                  ),
                  Expanded(
                    child: ListView.builder(
                      itemCount: discoveredDevices.length,
                      itemBuilder: (context, index) {
                        var device = discoveredDevices[index];

                        return ListTile(
                          title: Text(device.name),
                          subtitle: Text(device.ipAddress.address),
                          leading: const Icon(Icons.devices),
                          onTap: () => connectDevice(device),
                        );
                      },
                    ),
                  ),
                  SizedBox(height: 20),
                  Row(
                    mainAxisAlignment: MainAxisAlignment.end,
                    children: [
                      TextButton(
                        onPressed: () => connectDirectly(),
                        child: Text('Izravno povezivanje'),
                      ),
                      SizedBox(width: 20),
                      if (isDiscovering == false)
                        FilledButton(
                          onPressed: () => startScan(),
                          child: Text('Pretraži uređaje'),
                        ),
                      if (isDiscovering)
                        FilledButton(
                          onPressed: () => stopScan(),
                          child: Text('Zaustavi pretraživanje'),
                        ),
                    ],
                  ),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }

  @override
  void dispose() {
    deviceDiscovery.stop();
    super.dispose();
  }
}
