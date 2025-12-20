import 'package:flutter/widgets.dart';
import 'package:go_router/go_router.dart';
import 'package:smart_home_core/device.dart';
import 'package:smart_home_core/handler.dart';

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
}
