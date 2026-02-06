import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:smart_home_core/device.dart';
import 'package:smart_home_core/handler.dart';

import 'models/aq_device.dart';
import 'models/aq_device_context.dart';
import 'pages/aq_data_page.dart';
import 'pages/home_page.dart';
import 'pages/settings_page.dart';
import 'widgets/aq_appbar.dart';
import 'widgets/navigation.dart';

class AirQualityDeviceHandler extends DeviceHandler {
  AirQualityDeviceHandler() : super(DeviceType.airQuality);

  @override
  List<RouteBase> getRoutes() {
    return [
      ShellRoute(
        builder: (context, state, child) {
          var index = AppNavigation.getPageIndex(state.fullPath ?? '');
          var title = AppNavigation.getPageTitle(index);

          return Scaffold(
            appBar: AqAppBar(title: Text(title)),
            body: child,
            bottomNavigationBar: AppNavigation(selectedIndex: index),
          );
        },
        routes: [
          GoRoute(path: '/aq/home', builder: (context, state) => HomePage()),
          GoRoute(path: '/aq/settings', builder: (context, state) => SettingsPage()),
          GoRoute(
            path: '/aq/data',
            builder: (context, state) => AqDataPage(),
            routes: [
              GoRoute(
                path: 'live',
                builder: (context, state) => Center(child: Text('Live data')),
              ),
              GoRoute(
                path: 'recent',
                builder: (context, state) => Center(child: Text('Recent data')),
              ),
              GoRoute(
                path: 'history',
                builder: (context, state) => Center(child: Text('History data')),
              ),
            ],
          ),
        ],
      ),
    ];
  }

  @override
  void openHomePage(BuildContext context) {
    context.replace('/aq/home');
  }

  @override
  DeviceContext createDeviceContext(Device genericDevice) {
    var device = AqDevice.fromDevice(genericDevice);
    return AqDeviceContext(device);
  }
}
