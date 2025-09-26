import 'dart:async';
import 'dart:convert';

import 'package:air_quality/src/logic/exceptions.dart';
import 'package:http/http.dart' as http;

class DeviceClient {
  static const String _deviceHostname = 'air_quality_sensor.local';
  static const Duration _timeout = Duration(seconds: 4);

  Future<dynamic> httpGet(String path) async {
    try {
      var url = Uri.http(_deviceHostname, path);
      var response = await http.get(url).timeout(_timeout);

      if (response.statusCode != 200) {
        throw AppException(response.body);
      }

      return jsonDecode(response.body);
    } on Exception catch (e) {
      throw AppException('${e.runtimeType} $e');
    }
  }
}
