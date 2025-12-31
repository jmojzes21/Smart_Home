import 'dart:convert';

import 'package:http/http.dart' as http;

import '../../models/app_context.dart';
import '../../models/exceptions.dart';

class BackendClient {
  final Duration _timeout = Duration(seconds: 10);

  Future<dynamic> httpGet(String path, [Map<String, dynamic>? queryParameters]) async {
    try {
      var hostname = AppContext.instance.backendHostname;
      var url = Uri.http(hostname, path, queryParameters);
      var response = await http.get(url).timeout(_timeout);

      if (response.statusCode != 200) {
        throw AppException(response.body);
      }

      return jsonDecode(response.body);
    } on Exception catch (e) {
      throw AppException('${e.runtimeType} $e');
    }
  }

  Future<dynamic> httpPost(String path, Object body) async {
    String bodyJson = jsonEncode(body);

    try {
      var headers = {'Content-Type': 'application/json'};

      var hostname = AppContext.instance.backendHostname;
      var url = Uri.http(hostname, path);
      var response = await http.post(url, headers: headers, body: bodyJson, encoding: utf8).timeout(_timeout);

      if (response.statusCode != 200) {
        throw AppException(response.body);
      }

      return jsonDecode(response.body);
    } on Exception catch (e) {
      throw AppException('${e.runtimeType} $e');
    }
  }
}
