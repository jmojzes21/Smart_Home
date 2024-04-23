import 'package:smart_leds_app/logic/device_factory.dart';
import 'package:smart_leds_app/logic/session_service.dart';
import 'package:smart_leds_app/models/device/device.dart';
import 'package:smart_leds_app/models/exceptions.dart';
import 'package:smart_leds_app/models/session.dart';

class DeviceService {
  Future<void> login({
    required Device device,
    required String plainPassword,
    required bool stayLoggedIn,
  }) async {
    String password = device.hashPassword(plainPassword);

    await device.login(password);
    await device.getDeviceInfo();

    if (stayLoggedIn) {
      var sessionService = SessionService();
      await sessionService.saveSession(device, password);
    }
  }

  Future<Device?> restoreSession() async {
    var sessionService = SessionService();

    Session? session = await sessionService.loadSession();
    if (session == null) return null;

    var deviceFactory = DeviceFactory();
    var device = deviceFactory.fromSession(session);

    try {
      await device.getDeviceInfo();

      if (session.deviceType != device.type) return null;
      if (session.macAddress != device.macAddress) return null;

      await device.login(session.password);
      return device;
    } on DeviceException catch (_) {
      return null;
    }
  }
}
