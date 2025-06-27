import 'dart:io';

import 'package:shtc3_sensor_app/logic/ble_device_discovery.dart';
import 'package:shtc3_sensor_app/logic/device_controller.dart';
import 'package:shtc3_sensor_app/logic/fake_device_discovery.dart';

abstract class DeviceDiscovery {
  Future<List<DeviceController>> getBondedDevices();

  static DeviceDiscovery getDeviceDiscovery() {
    if (Platform.isAndroid) {
      return BleDeviceDiscovery();
    }
    return FakeDeviceDiscovery();
  }
}
