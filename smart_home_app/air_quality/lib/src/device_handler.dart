import 'package:flutter/widgets.dart';
import 'package:go_router/go_router.dart';
import 'package:smart_home_core/core.dart';
import 'package:smart_home_core/models.dart';

import 'pages/home_page.dart';

class AirQualityDeviceHandler extends DeviceHandler {
  AirQualityDeviceHandler() : super(DeviceType.airQuality);

  @override
  List<GoRoute> getRoutes() {
    return [GoRoute(path: '/aq/home', builder: (context, state) => HomePage())];
  }

  @override
  void openMainPage(BuildContext context) {
    context.push('/aq/home');
  }
}
