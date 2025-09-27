import 'dart:io';

import '../../logic/device/device.dart';

class Session {
  String deviceType = '';
  String ipAddress = '';
  String macAddress = '';
  String password = '';

  Session({required this.deviceType, required this.ipAddress, required this.macAddress, required this.password});

  Device getDevice() => Device(ipAddress: InternetAddress(ipAddress));

  factory Session.fromJson(Map<String, dynamic> src) {
    return Session(deviceType: src['deviceType'], ipAddress: src['ipAddress'], macAddress: src['macAddress'], password: src['password']);
  }

  static Map<String, dynamic> toJson(Session session) {
    return {'deviceType': session.deviceType, 'ipAddress': session.ipAddress, 'macAddress': session.macAddress, 'password': session.password};
  }
}
