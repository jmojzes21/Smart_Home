import 'dart:convert';
import 'dart:developer';
import 'dart:io';

import 'package:flutter/widgets.dart';
import 'package:go_router/go_router.dart';
import 'package:http/http.dart' as http;

import '../models/device.dart';
import '../models/device_context.dart';
import '../models/device_type.dart';
import '../models/exceptions.dart';

abstract class DeviceHandler {
  static const Duration _connectTimeout = Duration(seconds: 4);

  final DeviceType type;

  DeviceHandler(this.type);

  List<RouteBase> getRoutes();
  void openHomePage(BuildContext context);

  Future<DeviceContext> connectDevice(Device genericDevice);

  Future<void> checkAvailability(Device device) async {
    if (device.isVirtual) {
      return;
    }

    if (device.ipAddress == null) {
      var address = await _getIpAddress(device);
      device.ipAddress = address;
    }

    await _checkDeviceIdentity(device);
  }

  Future<InternetAddress> _getIpAddress(Device device) async {
    try {
      var result = await InternetAddress.lookup(device.hostname, type: InternetAddressType.IPv4);
      return result.first;
    } catch (e) {
      log(e.toString());
      throw AppException('Uređaj nije dostupan.');
    }
  }

  Future<void> _checkDeviceIdentity(Device device) async {
    try {
      var url = Uri.http(device.ipAddress!.address, '/device');
      var response = await http.get(url).timeout(_connectTimeout);

      if (response.statusCode != 200) {
        throw AppException(response.body);
      }

      var json = jsonDecode(response.body);

      var type = DeviceType.parse(json['type']);
      String hostname = json['hostname'];

      if (type != device.type || hostname != device.hostname.trim()) {
        throw AppException(response.body);
      }
    } catch (e) {
      log(e.toString());
      throw AppException('Povezivanje na uređaj nije moguće.');
    }
  }
}
