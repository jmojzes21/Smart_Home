import 'package:flutter/widgets.dart';
import 'package:provider/provider.dart';
import 'package:smart_home_core/device.dart';

import '../logic/services/device_client.dart';
import '../logic/services/service_factory.dart';
import 'aq_device.dart';

class AqDeviceContext extends DeviceContext<AqDevice> {
  late final DeviceClient client;
  late final ServiceFactory serviceFactory;

  AqDeviceContext(super.device) {
    client = DeviceClient(device);
    serviceFactory = ServiceFactory(client);
  }

  static AqDeviceContext of(BuildContext context) {
    return context.read<DeviceManager>().deviceContext as AqDeviceContext;
  }
}
