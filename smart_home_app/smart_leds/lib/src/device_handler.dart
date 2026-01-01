import 'package:flutter/widgets.dart';
import 'package:go_router/go_router.dart';
import 'package:smart_home_core/device.dart';
import 'package:smart_home_core/handler.dart';

import 'models/smart_leds_device.dart';
import 'models/smart_leds_device_context.dart';
import 'pages/home.dart';

class SmartLedsDeviceHandler extends DeviceHandler {
  SmartLedsDeviceHandler() : super(DeviceType.smartLeds);

  @override
  List<GoRoute> getRoutes() {
    return [GoRoute(path: '/leds/home', builder: (context, state) => HomePage())];
  }

  @override
  void openHomePage(BuildContext context) {
    context.push('/leds/home');
  }

  @override
  DeviceContext createDeviceContext(Device genericDevice) {
    var device = SmartLedsDevice.fromDevice(genericDevice);
    return SmartLedsDeviceContext(device);
  }
}
