import 'dart:convert';

import 'package:http/http.dart' as http;

import 'device.dart';
import 'device_info.dart';

class RealDevice extends Device {
  int httpPort;

  RealDevice({
    required super.name,
    required super.ipAddress,
    required this.httpPort,
  });

  @override
  Future<DeviceInfo> getDeviceInfo() async {
    var res = await http.get(Uri.http(ipAddress.address, '/device'));

    var json = jsonDecode(res.body);
    var info = DeviceInfo.fromJson(json);

    return info;
  }
}
