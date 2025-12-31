import 'package:go_router/go_router.dart';

import 'device_handlers.dart';
import 'pages/devices_page.dart';
import 'pages/login_page.dart';

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
      GoRoute(
        path: '/devices',
        builder: (context, state) {
          return DevicesPage(deviceHandlers: DeviceHandlers.instance);
        },
      ),
    ],
  );

  void addRoutes(List<GoRoute> routes) {
    goRouter.configuration.routes.addAll(routes);
  }
}
