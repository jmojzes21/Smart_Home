import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';

import 'device_handlers.dart';
import 'pages/devices_page.dart';
import 'pages/login_page.dart';
import 'pages/profile_page.dart';
import 'widgets/navigation.dart';

class AppRoutes {
  final goRouter = GoRouter(
    initialLocation: '/login',
    routes: [
      GoRoute(path: '/', redirect: (context, state) => '/devices'),
      GoRoute(
        path: '/login',
        builder: (context, state) {
          return LoginPage();
        },
      ),
      ShellRoute(
        builder: (context, state, child) {
          var index = AppNavigation.getPageIndex(state.fullPath ?? '');
          var title = AppNavigation.getPageTitle(index);
          return Scaffold(
            appBar: AppBar(title: Text(title)),
            body: child,
            bottomNavigationBar: AppNavigation(selectedIndex: index),
          );
        },
        routes: [
          GoRoute(
            path: '/devices',
            pageBuilder: (context, state) {
              return NoTransitionPage(child: DevicesPage(deviceHandlers: DeviceHandlers.instance));
            },
          ),
          GoRoute(
            path: '/profile',
            pageBuilder: (context, state) {
              return NoTransitionPage(child: ProfilePage());
            },
          ),
        ],
      ),
    ],
  );

  void addRoutes(List<GoRoute> routes) {
    goRouter.configuration.routes.addAll(routes);
  }
}
