import 'package:flutter/widgets.dart';
import 'package:provider/provider.dart';
import 'package:smart_home_core/device.dart';

import '../logic/services/device_client.dart';
import '../logic/services/interfaces/air_quality_service.dart';
import '../logic/services/interfaces/device_service.dart';
import '../logic/services/service_factory.dart';
import 'aq_device.dart';

class AqDeviceContext extends DeviceContext<AqDevice> {
  late final DeviceClient client;

  late final IDeviceService deviceService;
  late final IAirQualityService airQualityService;

  AqDeviceContext(super.device) {
    client = DeviceClient(device);

    var serviceFactory = ServiceFactory(client);
    deviceService = serviceFactory.getDeviceService();
    airQualityService = serviceFactory.getAirQualityService();
  }

  static AqDeviceContext of(BuildContext context) {
    return context.read<DeviceManager>().deviceContext as AqDeviceContext;
  }
}
