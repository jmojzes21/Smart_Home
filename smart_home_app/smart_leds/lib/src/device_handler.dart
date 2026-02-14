import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:smart_home_core/device.dart';
import 'package:smart_home_core/handler.dart';

import 'models/smart_leds_device.dart';
import 'models/smart_leds_device_context.dart';
import 'pages/home.dart';

class SmartLedsDeviceHandler extends DeviceHandler {
  SmartLedsDeviceHandler() : super(DeviceType.smartLeds);

  @override
  List<RouteBase> getRoutes() {
    return [GoRoute(path: '/leds/home', builder: (context, state) => HomePage())];
  }

  @override
  void openHomePage(BuildContext context) {
    context.replace('/leds/home');
  }

  @override
  Future<DeviceContext> connectDevice(Device genericDevice) async {
    await checkAvailability(genericDevice);

    var device = SmartLedsDevice.fromDevice(genericDevice);
    return SmartLedsDeviceContext(device);
  }
}
