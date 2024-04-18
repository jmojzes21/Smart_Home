import 'package:flutter/material.dart';
import 'package:smart_leds_app/logic/device_discovery.dart';
import 'package:smart_leds_app/models/device.dart';
import 'package:smart_leds_app/pages/home_page.dart';
import 'package:smart_leds_app/widgets/message_dialogs.dart';

import '../logic/device_factory.dart';
import '../models/discovered_device.dart';

class DeviceDiscoveryPage extends StatefulWidget {
  const DeviceDiscoveryPage({super.key});
  @override
  State<DeviceDiscoveryPage> createState() => _DeviceDiscoveryPageState();
}

class _DeviceDiscoveryPageState extends State<DeviceDiscoveryPage> {
  var deviceDiscovery = DeviceDiscovery();
  var discoveredDevices = <DiscoveredDevice>[];
  var isDiscovering = false;
  var showVirtualDevice = true;

  @override
  void initState() {
    super.initState();
  }

  void startScan() async {
    try {
      await _startScan();
    } on Exception catch (_) {
      if (!mounted) return;
      showMessageDialog(context, 'Pretraživanje uređaja',
          'Greška prilikom pretraživanja uređaja!');
    }
  }

  Future<void> _startScan() async {
    setState(() {
      isDiscovering = true;
      discoveredDevices.clear();

      if (showVirtualDevice) {
        discoveredDevices.add(DiscoveredDevice.virtual());
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

  void openDevice(DiscoveredDevice discoveredDevice) {
    var deviceFactory = DeviceFactory();
    var device = deviceFactory.createDevice(discoveredDevice);

    Device.currentDevice = device;

    Navigator.of(context).pushReplacement(
      MaterialPageRoute(
        builder: (context) {
          return HomePage();
        },
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Center(
        child: SizedBox(
          width: 400,
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
                  trailing:
                      isDiscovering ? const CircularProgressIndicator() : null,
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
                        onTap: () => openDevice(device),
                      );
                    },
                  ),
                ),
                SizedBox(height: 20),
                if (isDiscovering == false)
                  ElevatedButton(
                    onPressed: () => startScan(),
                    child: Text('Pretraži uređaje'),
                  ),
                if (isDiscovering)
                  ElevatedButton(
                    onPressed: () => stopScan(),
                    child: Text('Zaustavi pretraživanje'),
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
    deviceDiscovery.stop();
    super.dispose();
  }
}
