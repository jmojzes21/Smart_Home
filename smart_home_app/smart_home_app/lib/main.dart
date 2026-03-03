import 'package:flutter/material.dart';
import 'package:flutter_localizations/flutter_localizations.dart';
import 'package:provider/provider.dart';
import 'package:smart_home_core/device.dart';

import 'device_handlers.dart';
import 'routes.dart';

final appRoutes = AppRoutes();

void main() {
  var deviceHandlers = DeviceHandlers.instance;
  for (var handler in deviceHandlers.handlers) {
    appRoutes.addRoutes(handler.getRoutes());
  }

  runApp(MainApp());
}

class MainApp extends StatelessWidget {
  const MainApp({super.key});

  @override
  Widget build(BuildContext context) {
    return Provider<DeviceManager>(
      create: (context) => DeviceManager(),
      child: MaterialApp.router(
        debugShowCheckedModeBanner: false,
        theme: ThemeData(
          colorSchemeSeed: Colors.blue,
          appBarTheme: AppBarTheme(backgroundColor: Colors.blue.shade900, foregroundColor: Colors.white),
          floatingActionButtonTheme: FloatingActionButtonThemeData(
            backgroundColor: Colors.blue.shade900,
            foregroundColor: Colors.white,
          ),
        ),
        localizationsDelegates: const [
          GlobalMaterialLocalizations.delegate,
          GlobalWidgetsLocalizations.delegate,
          GlobalCupertinoLocalizations.delegate,
        ],
        routerConfig: appRoutes.goRouter,
      ),
    );
  }
}
