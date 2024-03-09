class AppException implements Exception {
  final String message;
  AppException(this.message);

  @override
  String toString() => message;
}

class DeviceException extends AppException {
  DeviceException(super.message);
}

class FirmwareException extends AppException {
  FirmwareException(super.message);
}

class InvalidFirmwareFileException extends FirmwareException {
  InvalidFirmwareFileException() : super('Datoteka programa nije valjana.');
}

class FirmwareUpdateException extends AppException {
  FirmwareUpdateException(super.message);
}
