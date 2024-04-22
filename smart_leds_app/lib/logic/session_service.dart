import 'dart:convert';
import 'dart:io';

import 'package:smart_leds_app/models/device/device.dart';
import 'package:smart_leds_app/models/session.dart';

import 'package:path_provider/path_provider.dart' as pp;

class SessionService {
  Future<void> saveSession(Device device, String password) async {
    var session = Session(
      deviceType: device.type,
      ipAddress: device.ipAddress.address,
      macAddress: device.macAddress,
      password: password,
    );

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
