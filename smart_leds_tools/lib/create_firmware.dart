import 'dart:convert';
import 'dart:io';
import 'dart:typed_data';

import 'package:crypto/crypto.dart';
import 'package:path/path.dart' as p;

void main() {
  String rawFirmwarePath = p.join(p.current, '..', 'smart_leds_esp32', '.pio',
      'build', 'esp32dev', 'firmware.bin');

  String mainCppPath =
      p.join(p.current, '..', 'smart_leds_esp32', 'src', 'main.cpp');

  List<int> hmacKey = [
    72, 4, 232, 223, 231, 86, 70, 190, 236, 105, 77, 223, 246, 182, 30, 25, 74,
    56, 46, 220, 149, 246, 4, 222, 9, 218, 211, 62, 152, 170, 22, 141 //
  ];

  String firmwarePath = p.join(p.current, 'out', 'firmware.bin');

  Uint8List firmware = createFirmware(
    version: getFirmwareVersion(mainCppPath),
    rawFirmware: getRawFirmware(rawFirmwarePath),
    hmacKey: hmacKey,
  );

  File firmwareFile = File(firmwarePath);
  firmwareFile.writeAsBytesSync(firmware);

  print('Gotovo');
}

Uint8List createFirmware({
  required String version,
  required Uint8List rawFirmware,
  required List<int> hmacKey,
}) {
  print('Kreiraj konačni firmware');

  // struktura firmware datoteke
  //
  // 40 B - verzija programa
  // 4 B - veličina programa u bajtima
  // 32 B - HMAC-SHA256 od programa
  // program

  // verzija programa

  var versionBytes = Utf8Encoder().convert(version.padRight(40, ' '));
  if (versionBytes.length != 40) {
    throw 'Veličina mora biti 40';
  }

  // veličina programa

  var sizeBytes = ByteData(4);
  sizeBytes.setUint32(0, rawFirmware.length, Endian.little);

  // hmac programa

  var hmac = Hmac(sha256, ''.codeUnits);
  var digest = hmac.convert(rawFirmware);

  // kreiraj konačnu firmware datoteku

  var builder = BytesBuilder();

  builder.add(versionBytes);
  builder.add(sizeBytes.buffer.asUint8List());
  builder.add(digest.bytes);
  builder.add(rawFirmware);

  return builder.toBytes();
}

String getFirmwareVersion(String mainCppPath) {
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

Uint8List getRawFirmware(String firmwarePath) {
  print('Dohvati čisti firmware');

  var firmwareFile = File(firmwarePath);
  if (firmwareFile.existsSync() == false) {
    throw 'Nije moguće pronaći firmware datoteku';
  }

  Uint8List firmware = firmwareFile.readAsBytesSync();

  print(
      'Dohvaćeno, veličina: ${(firmware.length / (1024 * 1024)).toStringAsFixed(2)} MB');

  return firmware;
}
