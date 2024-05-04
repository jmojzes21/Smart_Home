class AppException implements Exception {
  final String message;
  AppException(this.message);

  @override
  String toString() => message;
}

class DeviceException extends AppException {
  DeviceException(String? message) : super(message ?? 'Nepoznata greška.');
}

class DeviceNotConnectedException extends DeviceException {
  DeviceNotConnectedException() : super('Uređaj nije povezan.');
}

class DeviceAuthenticationException extends DeviceException {
  DeviceAuthenticationException() : super('Autentifikacija nije uspjela.');
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
