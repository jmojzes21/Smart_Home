import 'package:flutter/widgets.dart';
import 'package:go_router/go_router.dart';
import 'package:smart_home_core/device.dart';
import 'package:smart_home_core/handler.dart';

import 'models/aq_device.dart';
import 'models/aq_device_context.dart';
import 'pages/home_page.dart';

class AirQualityDeviceHandler extends DeviceHandler {
  AirQualityDeviceHandler() : super(DeviceType.airQuality);

  @override
  List<GoRoute> getRoutes() {
    return [GoRoute(path: '/aq/home', builder: (context, state) => HomePage())];
  }

  @override
  void openHomePage(BuildContext context) {
    context.replace('/aq/home');
  }

  @override
  DeviceContext createDeviceContext(Device genericDevice) {
    var device = AqDevice.fromDevice(genericDevice);
    return AqDeviceContext(device);
  }
}
