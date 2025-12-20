import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:smart_home_core/models.dart';

import 'device_handlers.dart';
import 'routes.dart';

final appRoutes = AppRoutes();
final deviceHandlers = DeviceHandlers();

void main() {
  for (var deviceHandler in deviceHandlers.handlers) {
    appRoutes.addRoutes(deviceHandler.getRoutes());
  }

  runApp(const MainApp());
}

class MainApp extends StatelessWidget {
  const MainApp({super.key});

  @override
  Widget build(BuildContext context) {
    return Provider<DeviceHandlers>.value(
      value: deviceHandlers,
      child: Provider<DeviceContext>(
        create: (context) => DeviceContext(),
        child: MaterialApp.router(
          debugShowCheckedModeBanner: false,
          theme: ThemeData(colorSchemeSeed: Colors.blue),
          routerConfig: appRoutes.goRouter,
        ),
      ),
    );
  }
}
