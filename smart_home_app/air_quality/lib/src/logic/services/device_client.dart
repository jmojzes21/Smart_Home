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

    String body = response.body.trim();

    if (response.statusCode != 200) {
      throw AppException(body);
    }

    return jsonDecode(body);
  }

  Future<dynamic> _httpPostLike(String method, String path, Object body, int statusCode) async {
    var headers = {'Content-Type': 'application/json'};
    String bodyJson = jsonEncode(body);

    var hostname = device.ipAddress!.address;
    var url = Uri.http(hostname, path);

    http.Response response;
    if (method == 'post') {
      response = await http.post(url, headers: headers, body: bodyJson, encoding: utf8).timeout(_timeout);
    } else if (method == 'patch') {
      response = await http.patch(url, headers: headers, body: bodyJson, encoding: utf8).timeout(_timeout);
    } else {
      throw ArgumentError('Unsupported method $method');
    }

    String responseBody = response.body.trim();

    if (response.statusCode != statusCode) {
      throw AppException(responseBody);
    }

    if (responseBody.isEmpty) {
      return '';
    }

    return jsonDecode(responseBody);
  }

  Future<dynamic> httpPost(String path, Object body, {int statusCode = 200}) async {
    return _httpPostLike('post', path, body, statusCode);
  }

  Future<dynamic> httpPatch(String path, Object body, {int statusCode = 200}) async {
    return _httpPostLike('patch', path, body, statusCode);
  }

  Future<void> httpDelete(String path) async {
    var hostname = device.ipAddress!.address;
    var url = Uri.http(hostname, path);
    var response = await http.delete(url);

    String responseBody = response.body.trim();

    if (response.statusCode != 202) {
      throw AppException(responseBody);
    }
  }
}
