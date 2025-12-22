import 'package:flutter/widgets.dart';
import 'package:go_router/go_router.dart';
import 'package:smart_home_core/device.dart';
import 'package:smart_home_core/handler.dart';

import 'models/aq_device.dart';
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
  Device createDevice(Device genericDevice) {
    return AirQualityDevice.fromDevice(genericDevice);
  }
}
