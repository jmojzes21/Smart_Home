import 'dart:io';

import 'package:http/http.dart' as http;

Future<void> main(List<String> args) async {
  var ipAddress = readIpAddress(args);
  print('Prenesi ugradbeni program na uređaj ${ipAddress.address}');

  print('Gotovo');
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
