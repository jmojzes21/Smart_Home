import 'dart:async';
import 'dart:convert';

import 'package:smart_home_core/models.dart';

import '../exceptions.dart';
import 'package:http/http.dart' as http;

class DeviceClient {
  static const Duration _timeout = Duration(seconds: 4);

  final Device device;

  DeviceClient(this.device);

  Future<dynamic> httpGet(String path) async {
    try {
      var url = Uri.http(device.ipAddress!.address, path);
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
