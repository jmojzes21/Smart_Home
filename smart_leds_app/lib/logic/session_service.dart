import 'dart:convert';
import 'dart:io';

import 'package:smart_leds_app/models/device/device_info.dart';
import 'package:smart_leds_app/models/session.dart';

import 'package:path_provider/path_provider.dart' as pp;

class SessionService {
  void loadSession() async {}

  Future<void> saveSession(DeviceInfo info, String password) async {
    var session = Session(
        deviceType: info.type,
        ipAddress: info.ipAddress,
        macAddress: info.macAddress,
        password: password);

    var json = jsonEncode(Session.toJson(session));

    var docsDir = await pp.getApplicationDocumentsDirectory();
    var appDir = Directory('${docsDir.path}/Smart LEDs');

    if (await appDir.exists() == false) {
      await appDir.create();
    }

    var sessionFile = File('${appDir.path}/session.txt');
    await sessionFile.writeAsString(json);
  }
}
