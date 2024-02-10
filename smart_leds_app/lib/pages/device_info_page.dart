import 'package:flutter/material.dart';
import 'package:flutter/widgets.dart';
import 'package:smart_leds_app/models/device.dart';
import 'package:smart_leds_app/models/device_info.dart';
import 'package:smart_leds_app/widgets/navigation_drawer.dart';

class DeviceInfoPage extends StatefulWidget {
  const DeviceInfoPage({super.key});
  @override
  State<DeviceInfoPage> createState() => _DeviceInfoPageState();
}

class _DeviceInfoPageState extends State<DeviceInfoPage> {
  DeviceInfo? deviceInfo;

  @override
  void initState() {
    super.initState();
    getDeviceInfo();
  }

  void getDeviceInfo() async {
    Device.currentDevice.getDeviceInfo().then((value) {
      setState(() {
        deviceInfo = value;
      });
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('O uređaju'),
      ),
      drawer: AppNavigationDrawer(),
      body: buildBody(),
    );
  }

  Widget buildBody() {
    if (deviceInfo == null) {
      return Center(
        child: SizedBox.square(
          dimension: 100,
          child: CircularProgressIndicator(),
        ),
      );
    }
    return Padding(
      padding: const EdgeInsets.all(40),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text('Naziv: ${deviceInfo?.name}'),
          Text('Verzija: ${deviceInfo?.firmwareVersion}'),
          Text('WiFi mreža: ${deviceInfo?.wifiSSID}'),
          Text('WiFi RSSI: ${deviceInfo?.wifiRSSI}'),
          Text('IP adresa: ${deviceInfo?.ipAddress}'),
          Text('MAC adresa: ${deviceInfo?.macAddress}'),
        ],
      ),
    );
  }

  @override
  void dispose() {
    super.dispose();
  }
}
