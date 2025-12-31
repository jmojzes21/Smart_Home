import 'package:flutter/material.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';
import 'package:provider/provider.dart';
import 'package:smart_home_core/device.dart';
import 'package:smart_home_core/extensions.dart';
import 'package:smart_home_core/handler.dart';
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
        onShowMessage: (message) {
          if (context.mounted) Dialogs.showSnackBar(context, message);
        },
      ),
      child: Consumer<DevicesPageViewModel>(builder: (context, model, child) => buildBody(context, model)),
    );
  }

  Widget buildBody(BuildContext context, DevicesPageViewModel model) {
    if (model.isLoading && model.devices.isEmpty) {
      return Center(child: CircularProgressIndicator());
    }

    var enableButtons = !model.isLoading;

    return Stack(
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
                        deviceHandler: deviceHandlers.getDeviceHandler(device.type),
                        isDiscovering: model.isDiscovering,
                      );
                    },
                  ),
                SizedBox(height: 20),

                if (!model.isDiscovering)
                  TextButton(onPressed: () => model.startScan(), child: Text('Provjeri dostupnost')),
                if (model.isDiscovering)
                  TextButton(onPressed: () => model.stopScan(), child: Text('Zaustavi provjeru')),
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
  final GenericDevice device;
  final DeviceHandler? deviceHandler;

  final bool isDiscovering;

  const _DeviceWidget({required this.device, required this.deviceHandler, required this.isDiscovering});

  void openDevice(BuildContext context) {
    if (device.isOffline || deviceHandler == null) {
      return;
    }

    var deviceManager = context.read<DeviceManager>();
    var specificDevice = deviceHandler!.createDevice(device);

    deviceManager.setDevice(specificDevice);
    deviceHandler!.openHomePage(context);
  }

  @override
  Widget build(BuildContext context) {
    Widget subtitle;

    if (device.isOnline) {
      subtitle = Text(device.ipAddress?.address ?? 'Dostupan');
    } else {
      subtitle = isDiscovering ? Text('Pretraživanje...') : Text('Nedostupan');
    }

    return ListTile(
      onTap: () => openDevice(context),
      leading: Icon(Icons.devices),
      title: Text(device.name),
      subtitle: subtitle,
    );
  }
}
