import 'package:flutter/widgets.dart';
import 'package:go_router/go_router.dart';

import '../models/device.dart';

abstract class DeviceHandler {
  final DeviceType type;

  DeviceHandler(this.type);

  List<GoRoute> getRoutes();
  void openHomePage(BuildContext context);

  Device createDevice(Device genericDevice);
}
