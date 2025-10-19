import 'package:go_router/go_router.dart';
import 'package:provider/provider.dart';

import 'device_handlers.dart';
import 'pages/devices_page.dart';

class AppRoutes {
  final goRouter = GoRouter(
    initialLocation: '/devices',
    routes: [
      GoRoute(
        path: '/devices',
        builder: (context, state) {
          var deviceHandlers = context.read<DeviceHandlers>();
          return DevicesPage(deviceHandlers: deviceHandlers);
        },
      ),
    ],
  );

  void addRoutes(List<GoRoute> routes) {
    goRouter.configuration.routes.addAll(routes);
  }
}
