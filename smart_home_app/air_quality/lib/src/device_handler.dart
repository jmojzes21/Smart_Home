import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:smart_home_core/device.dart';
import 'package:smart_home_core/handler.dart';

import 'models/aq_device.dart';
import 'models/aq_device_context.dart';
import 'pages/aq_data_selection_page.dart';
import 'pages/aq_history_data_page.dart';
import 'pages/aq_live_data_page.dart';
import 'pages/aq_recent_data_page.dart';
import 'pages/home_page.dart';
import 'pages/advanced_page.dart';
import 'widgets/navigation.dart';

class AirQualityDeviceHandler extends DeviceHandler {
  AirQualityDeviceHandler() : super(DeviceType.airQuality);

  @override
  List<RouteBase> getRoutes() {
    return [
      ShellRoute(
        builder: (context, state, child) {
          var index = AppNavigation.getPageIndex(state.fullPath ?? '');
          return Scaffold(
            body: child,
            bottomNavigationBar: AppNavigation(selectedIndex: index),
          );
        },
        routes: [
          GoRoute(path: '/aq/home', builder: (context, state) => HomePage()),
          GoRoute(path: '/aq/advanced', builder: (context, state) => AdvancedPage()),

          GoRoute(
            path: '/aq/data',
            builder: (context, state) => AqDataSelectionPage(),
            routes: [
              GoRoute(path: 'live', builder: (context, state) => AqLiveDataPage()),
              GoRoute(path: 'recent', builder: (context, state) => AqRecentDataPage()),
              GoRoute(path: 'history', builder: (context, state) => AqHistoryDataPage()),
            ],
          ),
        ],
      ),
    ];
  }

  @override
  void openHomePage(BuildContext context) {
    context.go('/aq/home');
  }

  @override
  Future<DeviceContext> connectDevice(Device genericDevice) async {
    await checkAvailability(genericDevice);

    var device = AqDevice.fromDevice(genericDevice);
    return AqDeviceContext(device);
  }
}
