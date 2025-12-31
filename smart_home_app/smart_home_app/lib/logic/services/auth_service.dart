import 'package:smart_home_core/models.dart';
import 'package:smart_home_core/services.dart';

import 'interfaces/auth_service.dart';

class AuthService implements IAuthService {
  @override
  Future<void> login(String username, String password) async {
    if (username.isEmpty) {
      throw AppException('Potrebno je unijeti korisničko ime.');
    }

    if (password.isEmpty) {
      throw AppException('Potrebno je unijeti lozinku.');
    }

    var client = BackendClient();

    try {
      var response = await client.httpPost('/api/auth/user/login', {'username': username, 'password': password});

      User user = User.fromJson(response);
      AppContext.instance.currentUser = user;
    } on Exception catch (_) {
      throw AppException('Prijava nije uspjela! Provjerite korisničko ime i lozinku.');
    }
  }
}
