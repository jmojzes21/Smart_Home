import 'package:smart_home_core/models.dart';
import 'package:smart_home_core/view_model.dart';

import '../services/interfaces/auth_service.dart';
import '../services/interfaces/device_service.dart';

class ProfilePageViewModel extends ViewModel {
  late User _user;

  final IAuthService authService;
  final IDeviceService deviceService;

  ProfilePageViewModel({required this.authService, required this.deviceService}) {
    _user = AppContext.instance.currentUser;
  }

  Future<void> logout() async {
    await authService.logout();
    await deviceService.deleteDevicesFromCache();
  }

  User get user => _user;
}
