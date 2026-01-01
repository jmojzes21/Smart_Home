import 'package:flutter/widgets.dart';
import 'package:go_router/go_router.dart';

import '../models/device.dart';
import '../models/device_context.dart';
import '../models/device_type.dart';

abstract class DeviceHandler {
  final DeviceType type;

  DeviceHandler(this.type);

  List<GoRoute> getRoutes();
  void openHomePage(BuildContext context);

  DeviceContext createDeviceContext(Device genericDevice);
}
