import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:smart_home_core/core.dart';
import '../device_handlers.dart';
import '../logic/services/device_discovery.dart';
import '../logic/services/mock/mock_device_service.dart';
import '../logic/vm/devices_page_vm.dart';
import 'package:smart_home_core/extensions.dart';
import 'package:smart_home_core/models.dart';

class DevicesPage extends StatelessWidget {
  final DeviceHandlers deviceHandlers;

  const DevicesPage({super.key, required this.deviceHandlers});

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
              itemBuilder: (context, index) {
                var device = model.devices[index];
                return _DeviceWidget(
                  device: device,
                  deviceHandler: deviceHandlers.getDeviceHandler(device.type),
                  isDiscovering: model.isDiscovering,
                );
              },
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
  final DeviceHandler? deviceHandler;

  final bool isDiscovering;

  const _DeviceWidget({required this.device, required this.deviceHandler, required this.isDiscovering});

  void openDevice(BuildContext context, Device device) {
    if (device.isOffline || deviceHandler == null) {
      return;
    }

    var deviceContext = context.read<DeviceContext>();
    deviceContext.device = device;

    deviceHandler!.openMainPage(context);
  }

  @override
  Widget build(BuildContext context) {
    Widget subtitle;

    if (device.isOnline) {
      subtitle = Text(device.ipAddress?.address ?? '');
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
