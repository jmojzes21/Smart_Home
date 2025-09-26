import 'dart:convert';
import 'dart:io';

import 'package:smart_leds/src/logic/device/device.dart';
import 'package:smart_leds/src/models/misc/session.dart';

import 'package:path_provider/path_provider.dart' as pp;

class SessionService {
  Future<Session?> loadSession() async {
    try {
      var docsDir = await pp.getApplicationDocumentsDirectory();
      var sessionFile = File('${docsDir.path}/Smart LEDs/session.txt');

      var sessionFileExists = await sessionFile.exists();
      if (sessionFileExists == false) {
        return null;
      }

      String text = await sessionFile.readAsString();
      var json = jsonDecode(text);
      var session = Session.fromJson(json);

      return session;
    } on Exception catch (_) {
      return null;
    }
  }

  Future<void> saveSession(Device device, String password) async {
    var session = Session(deviceType: device.type, ipAddress: device.ipAddress.address, macAddress: device.macAddress, password: password);

    var json = jsonEncode(Session.toJson(session));

    var docsDir = await pp.getApplicationDocumentsDirectory();
    var appDir = Directory('${docsDir.path}/Smart LEDs');

    var appDirExists = await appDir.exists();
    if (appDirExists == false) {
      await appDir.create();
    }

    var sessionFile = File('${appDir.path}/session.txt');
    await sessionFile.writeAsString(json);
  }

  Future<void> deleteSession() async {
    try {
      var docsDir = await pp.getApplicationDocumentsDirectory();
      var sessionFile = File('${docsDir.path}/Smart LEDs/session.txt');

      var sessionFileExists = await sessionFile.exists();
      if (sessionFileExists) {
        await sessionFile.delete();
      }
    } on Exception catch (_) {}
  }
}
