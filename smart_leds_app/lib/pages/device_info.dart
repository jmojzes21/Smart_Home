import 'package:flutter/material.dart';
import 'package:smart_leds_app/models/device/device.dart';
import 'package:smart_leds_app/widgets/misc/navigation_drawer.dart';

class DeviceInfoPage extends StatefulWidget {
  const DeviceInfoPage({super.key});
  @override
  State<DeviceInfoPage> createState() => _DeviceInfoPageState();
}

class _DeviceInfoPageState extends State<DeviceInfoPage> {
  late Device device;

  @override
  void initState() {
    super.initState();
    device = Device.currentDevice;
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
          Text(device.name, style: bodyStyle),
          SizedBox(height: spacing),
          Text('Verzija', style: titleStyle),
          Text(device.firmwareVersion, style: bodyStyle),
          SizedBox(height: spacing),
          Text('IP adresa', style: titleStyle),
          Text(device.ipAddress.address, style: bodyStyle),
          SizedBox(height: spacing),
          Text('MAC adresa', style: titleStyle),
          Text(device.macAddress, style: bodyStyle),
        ],
      ),
    );
  }

  @override
  void dispose() {
    super.dispose();
  }
}
