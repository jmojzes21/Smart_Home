import 'dart:convert';
import 'dart:io';
import 'dart:typed_data';

import 'package:smart_leds_app/models/exceptions.dart';
import 'package:smart_leds_app/models/misc/firmware.dart';

class FirmwareLoader {
  Future<Firmware> loadFirmware(String path) async {
    Uint8List bytes = await _readFileBytes(path);
    ByteData byteData = ByteData.sublistView(bytes);

    int offset = 0;

    _confirmRead(byteData, offset, 2);
    int headerSize = byteData.getUint16(offset, Endian.little);
    offset += 2;

    _confirmRead(byteData, offset, headerSize);
    Uint8List headerBytes = byteData.buffer.asUint8List(offset, headerSize);
    dynamic header = _parseHeader(headerBytes);
    offset += headerSize;

    _confirmRead(byteData, offset, 4);
    int firmwareSize = byteData.getUint32(offset, Endian.little);
    offset += 4;

    _confirmRead(byteData, offset, firmwareSize);
    Uint8List firmware = byteData.buffer.asUint8List(offset, firmwareSize);
    offset += firmwareSize;

    if (offset != byteData.lengthInBytes) {
      throw InvalidFirmwareFileException();
    }

    return Firmware(
      deviceType: header['deviceType'] ?? '',
      version: header['version'] ?? '',
      hmac: header['hmac'] ?? '',
      bytes: firmware,
    );
  }

  dynamic _parseHeader(Uint8List bytes) {
    try {
      String json = const Utf8Decoder().convert(bytes);
      return jsonDecode(json);
    } on Exception catch (_) {
      throw InvalidFirmwareFileException();
    }
  }

  void _confirmRead(ByteData byteData, int offset, int size) {
    if (byteData.lengthInBytes < offset + size) {
      throw InvalidFirmwareFileException();
    }
  }

  Future<Uint8List> _readFileBytes(String path) async {
    try {
      File file = File(path);
      return file.readAsBytes();
    } on Exception catch (_) {
      throw AppException('Nije moguće otvoriti datoteku programa.');
    }
  }
}
