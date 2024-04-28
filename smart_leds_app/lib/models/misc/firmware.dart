import 'dart:typed_data';

class Firmware {
  final String deviceType;
  final String version;
  final String hmac;

  final Uint8List bytes;

  Firmware({
    required this.deviceType,
    required this.version,
    required this.hmac,
    required this.bytes,
  });
}
