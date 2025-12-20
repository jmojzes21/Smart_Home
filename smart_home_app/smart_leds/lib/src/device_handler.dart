import 'package:flutter/widgets.dart';
import 'package:go_router/go_router.dart';
import 'package:smart_home_core/core.dart';
import 'package:smart_home_core/models.dart';

import 'pages/home.dart';

class SmartLedsDeviceHandler extends DeviceHandler {
  SmartLedsDeviceHandler() : super(DeviceType.smartLeds);

  @override
  List<GoRoute> getRoutes() {
    return [GoRoute(path: '/leds/home', builder: (context, state) => HomePage())];
  }

  @override
  void openMainPage(BuildContext context) {
    context.push('/leds/home');
  }
}
