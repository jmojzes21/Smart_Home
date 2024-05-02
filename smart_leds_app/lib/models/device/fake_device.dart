import 'dart:developer';
import 'dart:io';
import 'dart:math' as math;

import 'package:smart_leds_app/models/exceptions.dart';
import 'package:smart_leds_app/models/misc/firmware.dart';
import 'package:smart_leds_app/models/patterns/color_pattern.dart';
import 'package:smart_leds_app/models/misc/power_sensor_data.dart';
import 'package:smart_leds_app/models/misc/wifi_network.dart';
import 'package:smart_leds_app/models/patterns/pattern_property.dart';

import 'device.dart';

class VirtualDevice extends Device {
  final wifiNetworks = [
    WifiNetwork('Water', 'water'),
    WifiNetwork('Clound', 'cloud'),
    WifiNetwork('Forest', 'forest'),
  ];

  var isPowerSensorActive = false;
  var random = math.Random();

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
  Future<void> showPattern(
    ColorPattern pattern,
    PatternProperties properties,
  ) async {
    log('Prikaži svjetlosni uzorak ${pattern.toJson(properties)}');
  }

  @override
  Future<void> clearPattern() async {
    log('Očisti svjetlosni uzorak');
  }

  @override
  Future<List<WifiNetwork>> getWifiNetworks() async {
    await Future.delayed(Duration(milliseconds: 2000));
    return wifiNetworks;
  }

  @override
  Future<void> updateWifiNetworks(List<WifiNetwork> networks) async {
    wifiNetworks.clear();
    wifiNetworks.addAll(networks);
  }

  @override
  Future<void> setPowerSensorState(bool active) async {
    isPowerSensorActive = active;
  }

  @override
  Future<PowerSensorData> getPowerSensorData() async {
    var data = PowerSensorData();
    if (isPowerSensorActive) {
      data.isActive = true;

      data.current = random.nextInt(2000).toDouble();
      data.minCurrent = 20;
      data.maxCurrent = 2000;

      data.voltage = 4 + random.nextInt(1000).toDouble() / 1000;
      data.minVoltage = 4;
      data.maxVoltage = 5;
    }
    return data;
  }

  @override
  Future<void> updateFirmware(Firmware firmware) async {
    await Future.delayed(Duration(milliseconds: 4000));
    if (random.nextDouble() < 0.3) {
      throw FirmwareUpdateException('Nepoznata greška!');
    }
  }
}
