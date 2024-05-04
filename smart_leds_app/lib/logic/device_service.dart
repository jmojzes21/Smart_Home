import 'package:smart_leds_app/logic/session_service.dart';
import 'package:smart_leds_app/logic/device/device.dart';
import 'package:smart_leds_app/models/exceptions.dart';
import 'package:smart_leds_app/models/misc/session.dart';

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

    var device = session.getDevice();

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

  Future<void> deleteSession() async {
    var sessionService = SessionService();
    await sessionService.deleteSession();
  }

  Future<void> changePassword({
    required Device device,
    required String plainOldPassword,
    required String plainNewPassword,
  }) async {
    String oldPassword = device.hashPassword(plainOldPassword);
    String newPassword = device.hashPassword(plainNewPassword);

    await device.changePassword(oldPassword, newPassword);
  }
}
