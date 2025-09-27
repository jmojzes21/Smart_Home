import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:smart_home_app/logic/services/device_discovery.dart';
import 'package:smart_home_app/logic/services/mock/mock_device_service.dart';
import 'package:smart_home_app/logic/vm/devices_page_vm.dart';
import 'package:smart_home_core/extensions.dart';
import 'package:smart_home_core/models.dart';

import 'package:air_quality/air_quality.dart' as air_quality;
import 'package:smart_leds/smart_leds.dart' as smart_leds;

class DevicesPage extends StatelessWidget {
  const DevicesPage({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: ChangeNotifierProvider(
        create: (context) =>
            DevicesPageViewModel(deviceService: MockDeviceService(), deviceDiscovery: DeviceDiscovery()),
        child: Consumer<DevicesPageViewModel>(builder: (context, model, child) => buildBody(context, model)),
      ),
    );
  }

  Widget buildBody(BuildContext context, DevicesPageViewModel model) {
    return SingleChildScrollView(
      child: Padding(
        padding: EdgeInsets.all(20),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            ListTile(
              leading: model.isDiscovering ? CircularProgressIndicator() : null,
              title: Text('Moji uređaji', style: context.textTheme.titleLarge),
            ),
            SizedBox(height: 20),
            ListView.builder(
              itemCount: model.devices.length,
              shrinkWrap: true,
              itemBuilder: (context, index) =>
                  _DeviceWidget(device: model.devices[index], isDiscovering: model.isDiscovering),
            ),
            SizedBox(height: 20),
            if (!model.isDiscovering) FilledButton(onPressed: () => model.startScan(), child: Text('Pretraži uređaje')),
            if (model.isDiscovering)
              FilledButton(onPressed: () => model.stopScan(), child: Text('Zaustavi pretraživanje')),
          ],
        ),
      ),
    );
  }
}

class _DeviceWidget extends StatelessWidget {
  final Device device;
  final bool isDiscovering;

  const _DeviceWidget({required this.device, required this.isDiscovering});

  void openDevice(BuildContext context, Device device) {
    if (device.isOffline) {
      return;
    }

    switch (device.type) {
      case DeviceType.airQuality:
        Navigator.of(context).push(MaterialPageRoute(builder: (context) => air_quality.MainApp()));
        break;
      case DeviceType.smartLeds:
        Navigator.of(context).push(MaterialPageRoute(builder: (context) => smart_leds.MainApp()));
        break;
      default:
    }
  }

  @override
  Widget build(BuildContext context) {
    Widget subtitle;

    if (device.isOnline) {
      subtitle = Text(device.ipAddress!.address);
    } else {
      subtitle = isDiscovering ? Text('Pretraživanje...') : Text('Nedostupan');
    }

    return ListTile(
      onTap: () => openDevice(context, device),
      leading: Icon(Icons.devices),
      title: Text(device.name),
      subtitle: subtitle,
    );
  }
}
