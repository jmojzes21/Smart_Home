import 'package:path_provider/path_provider.dart';

import '../../models.dart';

class AppContext {
  static final AppContext _instance = AppContext._();
  static AppContext get instance => _instance;

  String _backendHostname = '';
  User? _currentUser;

  String? _appDirectory;

  AppContext._();

  Future<void> init() async {
    _appDirectory ??= (await getApplicationSupportDirectory()).path;
  }

  String get appDirectory => _appDirectory!;
  String get backendHostname => _backendHostname;
  set backendHostname(String value) => _backendHostname = value;

  User get currentUser => _currentUser!;
  set currentUser(User? user) => _currentUser = user;
}
