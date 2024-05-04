import 'dart:convert';
import 'dart:io';
import 'dart:typed_data';

import 'package:crypto/crypto.dart';
import 'package:path/path.dart' as p;

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

Firmware loadFirmware() {
  String deviceType = 'Smart LEDs L24';

  List<int> hmacKey = [
    72, 4, 232, 223, 231, 86, 70, 190, 236, 105, 77, 223, 246, 182, 30, 25, 74,
    56, 46, 220, 149, 246, 4, 222, 9, 218, 211, 62, 152, 170, 22, 141 //
  ];

  String firmwarePath = p.join(p.current, '..', '..', 'smart_leds_esp32',
      '.pio', 'build', 'esp32dev', 'firmware.bin');

  String mainCppPath =
      p.join(p.current, '..', '..', 'smart_leds_esp32', 'src', 'main.cpp');

  String version = _getFirmwareVersion(mainCppPath);
  Uint8List firmwareBytes = _getFirmware(firmwarePath);
  String hmac = _calculateHmac(firmwareBytes, hmacKey);

  return Firmware(
    version: version,
    deviceType: deviceType,
    hmac: hmac,
    bytes: firmwareBytes,
  );
}

String _getFirmwareVersion(String mainCppPath) {
  print('Dohvati verziju iz main.cpp datoteke');

  var mainCppFile = File(mainCppPath);
  if (mainCppFile.existsSync() == false) {
    throw 'Nije moguće pronaći main.cpp datoteku';
  }

  var lines = mainCppFile.readAsLinesSync();

  var version = '';

  for (var line in lines) {
    if (line.startsWith('const char* firmwareVersion =')) {
      var reg = RegExp(r'(\")([\w\.]+)(\")');
      var match = reg.firstMatch(line);

      if (match == null) break;
      version = match.group(2) ?? '';
    }
  }

  if (version.isEmpty) {
    throw 'Nije moguće pronaći verziju';
  }

  print('Verzija: $version');
  return version;
}

Uint8List _getFirmware(String firmwarePath) {
  print('Dohvati firmware');

  var firmwareFile = File(firmwarePath);
  if (firmwareFile.existsSync() == false) {
    throw 'Nije moguće pronaći firmware datoteku';
  }

  Uint8List firmware = firmwareFile.readAsBytesSync();

  print(
      'Dohvaćeno, veličina: ${(firmware.length / (1024 * 1024)).toStringAsFixed(2)} MB');

  return firmware;
}

String _calculateHmac(Uint8List input, List<int> key) {
  var hmac = Hmac(sha256, key);
  var digest = hmac.convert(input);

  return base64Encode(digest.bytes);
}
