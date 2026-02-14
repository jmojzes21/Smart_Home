import 'package:flutter/material.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';
import 'package:provider/provider.dart';
import 'package:smart_home_core/device.dart';
import 'package:smart_home_core/extensions.dart';
import 'package:smart_home_core/widgets.dart';
import '../device_handlers.dart';
import '../logic/services/device_discovery.dart';
import '../logic/services/device_service.dart';
import '../logic/vm/devices_page_vm.dart';

import '../models/generic_device.dart';

class DevicesPage extends StatelessWidget {
  final DeviceHandlers deviceHandlers;

  const DevicesPage({super.key, required this.deviceHandlers});

  @override
  Widget build(BuildContext context) {
    return ChangeNotifierProvider(
      create: (context) => DevicesPageViewModel(
        deviceService: DeviceService(),
        deviceDiscovery: DeviceDiscovery(),
        deviceHandlers: deviceHandlers,
        onShowMessage: (message) {
          if (context.mounted) Dialogs.showSnackBar(context, message);
        },
        onDeviceConnected: (handler, deviceContext) {
          if (!context.mounted) return;

          var deviceManager = context.read<DeviceManager>();
          deviceManager.setDeviceContext(deviceContext);
          handler.openHomePage(context);
        },
      ),
      child: Consumer<DevicesPageViewModel>(builder: (context, model, child) => buildBody(context, model)),
    );
  }

  Widget buildBody(BuildContext context, DevicesPageViewModel model) {
    if (model.isLoading && model.devices.isEmpty) {
      return Center(child: CircularProgressIndicator());
    }

    if (model.isConnecting) {
      return Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          spacing: 20,
          children: [
            CircularProgressIndicator(),
            Text('Povezivanje uređaja', style: context.textTheme.titleMedium),
          ],
        ),
      );
    }

    var enableButtons = !model.isLoading;

    return Stack(
      fit: StackFit.expand,
      children: [
        SingleChildScrollView(
          child: Padding(
            padding: EdgeInsets.all(20),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                if (model.devices.isEmpty) Text('Nema uređaja za prikazati.', style: context.textTheme.titleLarge),
                if (model.devices.isNotEmpty)
                  ListView.builder(
                    itemCount: model.devices.length,
                    shrinkWrap: true,
                    itemBuilder: (context, index) {
                      var device = model.devices[index];
                      return _DeviceWidget(
                        device: device,
                        isDiscovering: model.isDiscovering,
                        onConnect: () {
                          model.connectDevice(device);
                        },
                      );
                    },
                  ),
                SizedBox(height: 20),

                Row(
                  children: [
                    if (!model.isDiscovering)
                      TextButton(onPressed: () => model.startScan(), child: Text('Provjeri dostupnost')),
                    if (model.isDiscovering)
                      TextButton(onPressed: () => model.stopScan(), child: Text('Zaustavi provjeru')),
                    if (model.isDiscovering)
                      Padding(padding: EdgeInsets.only(left: 20), child: CircularProgressIndicator()),
                  ],
                ),
              ],
            ),
          ),
        ),
        Align(
          alignment: AlignmentGeometry.bottomRight,
          child: Padding(
            padding: EdgeInsets.all(20),
            child: FloatingActionButton(
              onPressed: enableButtons ? () => model.getDevices() : null,
              child: FaIcon(FontAwesomeIcons.arrowsRotate),
            ),
          ),
        ),
      ],
    );
  }
}

class _DeviceWidget extends StatelessWidget {
  final ScannedDevice device;
  final bool isDiscovering;
  final VoidCallback onConnect;

  const _DeviceWidget({required this.device, required this.isDiscovering, required this.onConnect});

  @override
  Widget build(BuildContext context) {
    Widget? subtitle;

    if (isDiscovering && device.availability != Availability.online) {
      subtitle = Text('Pretraživanje...');
    } else {
      if (device.availability == Availability.online) {
        subtitle = Text(device.ipAddress?.address ?? 'Dostupan');
      } else if (device.availability == Availability.offline) {
        subtitle = Text('Nedostupan');
      }
    }

    return ListTile(
      onTap: () => onConnect(),
      leading: Icon(Icons.devices),
      title: Text(device.name),
      subtitle: subtitle,
    );
  }
}
