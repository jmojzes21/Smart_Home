import 'dart:convert';
import 'dart:io';

import 'package:http/http.dart' as http;
import 'package:scripts/firmware.dart';

Future<void> main(List<String> args) async {
  var ipAddress = readIpAddress(args);
  print('Prenesi ugradbeni program na uređaj ${ipAddress.address}');

  Stopwatch stopwatch = Stopwatch();
  stopwatch.start();

  Firmware firmware = loadFirmware();
  await checkDeviceType(ipAddress, firmware.deviceType);
  await uploadFirmware(ipAddress, firmware);

  stopwatch.stop();
  double elapsed = stopwatch.elapsedMilliseconds / 1000;

  print('Gotovo, trajanje: ${elapsed.toStringAsFixed(2)} s');
}

Future<void> checkDeviceType(InternetAddress ipAddress, String type) async {
  var uri = Uri.http(ipAddress.address, 'device');
  var response = await http.get(uri);

  var json = jsonDecode(response.body);
  if (json['type'] != type) {
    throw 'Pogrešan uređaj';
  }
}

Future<void> uploadFirmware(
    InternetAddress ipAddress, Firmware firmware) async {
  var uri = Uri.http(ipAddress.address, 'firmware_update');
  var response = await http.post(
    uri,
    headers: {
      'Device-Type': firmware.deviceType,
      'Firmware-Size': firmware.bytes.length.toString(),
      'Firmware-HMAC': firmware.hmac,
    },
    body: firmware.bytes,
  );

  var json = jsonDecode(response.body);
  var msg = json['msg'];

  if (response.statusCode != 201) {
    throw Exception('${response.statusCode} $msg');
  }

  print('${response.statusCode} $msg');
}

InternetAddress readIpAddress(List<String> args) {
  if (args.isEmpty) {
    throw Exception('IP adresa uređaja nije definirana');
  }

  InternetAddress? ipAddress = InternetAddress.tryParse(args[0]);
  if (ipAddress == null) {
    throw Exception('IP adresa nije valjana');
  }

  return ipAddress;
}
