import 'package:flutter/widgets.dart';
import 'package:go_router/go_router.dart';

import '../../models.dart';

abstract class DeviceHandler {
  final DeviceType type;

  DeviceHandler(this.type);

  List<GoRoute> getRoutes();
  void openMainPage(BuildContext context);
}
