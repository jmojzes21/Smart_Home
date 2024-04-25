import 'package:flutter/material.dart';
import 'package:smart_leds_app/logic/device_discovery.dart';
import 'package:smart_leds_app/logic/device_service.dart';
import 'package:smart_leds_app/models/device/device.dart';
import 'package:smart_leds_app/models/exceptions.dart';
import 'package:smart_leds_app/widgets/dialogs/login.dart';
import 'package:smart_leds_app/pages/home.dart';
import 'package:smart_leds_app/widgets/dialogs/simple_dialogs.dart';
import 'package:smart_leds_app/widgets/message_dialogs.dart';

import '../logic/device_factory.dart';
import '../models/device/discovered_device.dart';

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
    loadSession();
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

  Future<void> connectDevice(DiscoveredDevice discoveredDevice) async {
    var result = await LoginDialog.show(context);
    if (result == null) return;

    var deviceFactory = DeviceFactory();
    var device = deviceFactory.fromDiscovery(discoveredDevice);

    var deviceService = DeviceService();

    try {
      await deviceService.login(
        device: device,
        plainPassword: result.password,
        stayLoggedIn: result.stayLoggedIn,
      );
    } on DeviceException catch (e) {
      if (!mounted) return;
      SimpleDialogs.showMessage(
        context: context,
        title: 'Prijava nije uspjela',
        message: e.message,
      );
      return;
    }

    if (!mounted) return;
    openHomePage(device);
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
                        onTap: () => connectDevice(device),
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
