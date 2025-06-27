import 'package:flutter_blue_plus/flutter_blue_plus.dart';
import 'package:permission_handler/permission_handler.dart';
import 'package:shtc3_sensor_app/logic/ble_device_controller.dart';
import 'package:shtc3_sensor_app/logic/device_controller.dart';
import 'package:shtc3_sensor_app/logic/device_discovery.dart';

class BleDeviceDiscovery implements DeviceDiscovery {
  @override
  Future<List<DeviceController>> getBondedDevices() async {
    if (await Permission.bluetoothScan.isGranted == false) {
      await Permission.bluetoothScan.request();
    }

    if (await Permission.bluetoothConnect.isGranted == false) {
      await Permission.bluetoothConnect.request();
    }

    var bondedDevices = await FlutterBluePlus.bondedDevices;
    return bondedDevices.map((e) => BleDeviceController(e)).toList();
  }
}
