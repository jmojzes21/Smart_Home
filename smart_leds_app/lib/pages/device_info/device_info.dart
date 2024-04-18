import 'package:flutter/material.dart';
import 'package:smart_leds_app/models/device/device.dart';
import 'package:smart_leds_app/models/device/device_info.dart';
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

    var theme = Theme.of(context).textTheme;
    var titleStyle = theme.titleMedium;
    var bodyStyle = theme.bodyMedium;
    const spacing = 10.0;

    return Padding(
      padding: const EdgeInsets.all(40),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text('Naziv', style: titleStyle),
          Text(deviceInfo!.name, style: bodyStyle),
          SizedBox(height: spacing),
          Text('Verzija', style: titleStyle),
          Text(deviceInfo!.firmwareVersion, style: bodyStyle),
          SizedBox(height: spacing),
          Text('WiFi mreža', style: titleStyle),
          Text(deviceInfo!.wifiSSID, style: bodyStyle),
          SizedBox(height: spacing),
          Text('WiFi RSSI', style: titleStyle),
          Text('${deviceInfo!.wifiRSSI} dBm', style: bodyStyle),
          SizedBox(height: spacing),
          Text('IP adresa', style: titleStyle),
          Text(deviceInfo!.ipAddress, style: bodyStyle),
          SizedBox(height: spacing),
          Text('MAC adresa', style: titleStyle),
          Text(deviceInfo!.macAddress, style: bodyStyle),
          SizedBox(height: 20),
          ElevatedButton(
            onPressed: () => getDeviceInfo(),
            child: Text('Osvježi'),
          ),
        ],
      ),
    );
  }

  @override
  void dispose() {
    super.dispose();
  }
}
