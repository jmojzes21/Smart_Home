import 'device/device.dart';

class DeviceService {
  Future<void> login({required Device device, required String plainPassword, required bool stayLoggedIn}) async {
    String password = device.hashPassword(plainPassword);

    await device.login(password);
    await device.getDeviceInfo();
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
