import 'dart:io';
import 'dart:math';

import 'package:smart_leds_app/models/exceptions.dart';
import 'package:smart_leds_app/models/firmware.dart';
import 'package:smart_leds_app/models/wifi_network.dart';

import 'device.dart';

class VirtualDevice extends Device {
  final _wifiNetworks = [
    WifiNetwork('Prva Wifi mreža', 'lozinka'),
    WifiNetwork('Druga Wifi mreža', 'lozinka'),
    WifiNetwork('Treća Wifi mreža', 'lozinka'),
  ];

  VirtualDevice() : super(ipAddress: InternetAddress('0.0.0.0'));

  @override
  Future<void> getDeviceInfo() {
    return Future.delayed(Duration(milliseconds: 500), () {
      name = 'Lažni uređaj';
      type = 'Smart LEDS L24';
      firmwareVersion = 'v1.0.0';
      macAddress = 'FF:FF:FF:FF:FF:FF';
    });
  }

  @override
  Future<void> login(String password) async {
    return Future.delayed(Duration(milliseconds: 500), () {
      if (password != hashPassword('test')) {
        throw DeviceException('Pogrešna lozinka!');
      }
    });
  }

  @override
  Future<List<WifiNetwork>> getWifiNetworks() async {
    await Future.delayed(Duration(milliseconds: 2000));
    return _wifiNetworks;
  }

  @override
  Future<void> updateWifiNetworks(List<WifiNetwork> networks) async {
    _wifiNetworks.clear();
    _wifiNetworks.addAll(networks);
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
