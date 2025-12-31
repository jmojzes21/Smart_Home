class Exceptions {
  static String getMessage(Object e) {
    if (e is AppException) {
      return e.message;
    }
    return e.toString();
  }
}

class AppException implements Exception {
  final String message;

  AppException(this.message);

  @override
  String toString() => message;
}
