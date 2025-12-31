import 'package:smart_home_core/models.dart';
import 'package:smart_home_core/view_model.dart';

import '../services/auth_service.dart';

class ProfilePageViewModel extends ViewModel {
  late User _user;

  final AuthService authService;

  ProfilePageViewModel(this.authService) {
    _user = AppContext.instance.currentUser;
  }

  Future<void> logout() async {
    await authService.logout();
  }

  User get user => _user;
}
