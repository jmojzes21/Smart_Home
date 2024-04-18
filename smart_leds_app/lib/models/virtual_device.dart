import 'dart:math';

import 'package:smart_leds_app/models/device_info.dart';
import 'package:smart_leds_app/models/exceptions.dart';
import 'package:smart_leds_app/models/firmware.dart';

import 'device.dart';

class VirtualDevice extends Device {
  bool _isLoggedIn = false;

  VirtualDevice({required super.name, required super.ipAddress});

  @override
  Future<DeviceInfo> getDeviceInfo() {
    return Future.delayed(
      Duration(milliseconds: 500),
      () {
        return DeviceInfo(
          name: 'Virtualni uređaj',
          firmwareVersion: '1.0.0',
          ipAddress: '127.0.0.1',
          macAddress: 'FF:FF:FF:FF:FF:FF',
          wifiSSID: 'WiFi Network',
          wifiRSSI: -20,
        );
      },
    );
  }

  @override
  bool get isLoggedIn => _isLoggedIn;

  @override
  Future<void> login(String password) async {
    return Future.delayed(Duration(milliseconds: 500), () {
      if (password != 'test') {
        throw DeviceException('Pogrešna lozinka!');
      }
      _isLoggedIn = true;
    });
  }

  @override
  Future<void> updateFirmware(Firmware firmware) async {
    await Future.delayed(Duration(milliseconds: 4000));

    var random = Random();
    if (random.nextDouble() < 0.3) {
      throw FirmwareUpdateException('Nepoznata greška.');
    }
  }
}
