import 'package:path_provider/path_provider.dart';

import '../../models.dart';

class AppContext {
  static final AppContext _instance = AppContext._();
  static AppContext get instance => _instance;

  String _backendHostname = 'localhost:8080';
  User? _currentUser;

  String? _appDirectory;

  AppContext._();

  Future<String> getAppDirectory() async {
    _appDirectory ??= (await getApplicationSupportDirectory()).path;
    return _appDirectory!;
  }

  String get backendHostname => _backendHostname;
  set backendHostname(String value) => _backendHostname = value;

  User get currentUser => _currentUser!;
  set currentUser(User user) => _currentUser = user;
}
