import 'dart:convert';
import 'dart:io';
import 'dart:typed_data';

import 'package:path/path.dart' as p;
import 'package:scripts/firmware.dart';

void main() {
  String outputPath = p.join(p.current, 'out', 'firmware.bin');
  print('Zapakiraj ugradbeni program');

  Firmware firmware = loadFirmware();
  Uint8List bytes = packFirmware(firmware);

  File outputFile = File(outputPath);
  outputFile.writeAsBytesSync(bytes);

  print('Gotovo');
}

Uint8List packFirmware(Firmware firmware) {
  var header = {
    'version': firmware.version,
    'deviceType': firmware.deviceType,
    'hmac': firmware.hmac,
  };

  var headerJson = jsonEncode(header);
  var headerBytes = Utf8Encoder().convert(headerJson);

  var headerSize = ByteData(2);
  headerSize.setUint16(0, headerBytes.length, Endian.little);

  var firmwareSize = ByteData(4);
  firmwareSize.setUint32(0, firmware.bytes.length, Endian.little);

  var builder = BytesBuilder();

  builder.add(headerSize.buffer.asUint8List());
  builder.add(headerBytes);

  builder.add(firmwareSize.buffer.asUint8List());
  builder.add(firmware.bytes);

  return builder.toBytes();
}
