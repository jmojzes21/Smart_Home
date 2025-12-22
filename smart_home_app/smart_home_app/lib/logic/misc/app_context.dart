import 'package:path_provider/path_provider.dart';

class AppContext {
  static String? _appDirectory;

  static Future<String> getAppDirectory() async {
    _appDirectory ??= (await getApplicationSupportDirectory()).path;
    return _appDirectory!;
  }
}
