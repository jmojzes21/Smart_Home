import 'dart:async';
import 'dart:convert';

import 'package:http/http.dart' as http;
import 'package:smart_home_core/exceptions.dart';

import '../../models/aq_device.dart';

class DeviceClient {
  static const Duration _timeout = Duration(seconds: 10);

  final AqDevice device;

  DeviceClient(this.device);

  Future<dynamic> httpGet(String path, [Map<String, dynamic>? queryParameters]) async {
    var hostname = device.ipAddress!.address;
    var url = Uri.http(hostname, path, queryParameters);
    var response = await http.get(url).timeout(_timeout);

    if (response.statusCode != 200) {
      throw AppException(response.body);
    }

    return jsonDecode(response.body);
  }

  Future<dynamic> httpPost(String path, Object body) async {
    var headers = {'Content-Type': 'application/json'};
    String bodyJson = jsonEncode(body);

    var hostname = device.ipAddress!.address;
    var url = Uri.http(hostname, path);

    var response = await http.post(url, headers: headers, body: bodyJson, encoding: utf8).timeout(_timeout);

    if (response.statusCode != 200) {
      throw AppException(response.body);
    }

    return jsonDecode(response.body);
  }
}
