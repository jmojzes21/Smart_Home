import 'dart:convert';
import 'dart:developer';
import 'dart:io';

import 'package:path/path.dart';
import 'package:smart_home_core/models.dart';
import 'package:smart_home_core/services.dart';

import 'interfaces/auth_service.dart';

class AuthService implements IAuthService {
  @override
  Future<void> login(String hostname, String username, String password, bool stayLoggedIn) async {
    if (hostname.isEmpty) {
      throw AppException('Potrebno je unijeti naziv poslužitelja.');
    }

    if (username.isEmpty) {
      throw AppException('Potrebno je unijeti korisničko ime.');
    }

    if (password.isEmpty) {
      throw AppException('Potrebno je unijeti lozinku.');
    }

    var appContext = AppContext.instance;
    appContext.backendHostname = hostname;

    var client = BackendClient();

    try {
      var response = await client.httpPost('/api/auth/user/login', {'username': username, 'password': password});
      User user = User.fromJson(response);

      if (stayLoggedIn) {
        await _saveSession(hostname, user);
      }

      appContext.currentUser = user;
    } catch (e) {
      log(Exceptions.getMessage(e));
      throw AppException('Prijava nije uspjela! Provjerite korisničko ime i lozinku.');
    }
  }

  @override
  Future<bool> loadSession() async {
    try {
      File file = _getSessionFie();
      if ((await file.exists()) == false) return false;

      dynamic sessionJson = jsonDecode(await file.readAsString());

      String hostname = sessionJson['hostname'];
      User user = User.fromJson(sessionJson['user']);

      var appContext = AppContext.instance;
      appContext.backendHostname = hostname.trim();
      appContext.currentUser = user;
    } on Exception catch (_) {
      return false;
    } on Error catch (_) {
      return false;
    }

    return true;
  }

  @override
  Future<void> logout() async {
    AppContext.instance.currentUser = null;

    try {
      File file = _getSessionFie();
      if ((await file.exists())) {
        await file.delete();
      }
    } on Exception catch (_) {}
  }

  Future<void> _saveSession(String hostname, User user) async {
    var session = {'hostname': hostname, 'user': user.toJson()};

    File file = _getSessionFie();
    await file.writeAsString(jsonEncode(session));
  }

  File _getSessionFie() {
    var appDir = AppContext.instance.appDirectory;
    return File(join(appDir, 'session.json'));
  }
}
