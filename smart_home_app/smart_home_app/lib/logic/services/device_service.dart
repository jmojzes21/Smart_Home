import 'dart:convert';
import 'dart:developer';
import 'dart:io';

import 'package:path/path.dart';
import 'package:smart_home_core/models.dart';
import 'package:smart_home_core/services.dart';

import '../../models/generic_device.dart';
import 'interfaces/device_service.dart';

class DeviceService implements IDeviceService {
  @override
  Future<List<GenericDevice>> getDevices() async {
    var username = AppContext.instance.currentUser.username;

    var client = BackendClient();
    var response = await client.httpGet('/api/users/$username/devices');

    return _parseDevices(response);
  }

  @override
  Future<List<GenericDevice>> getDevicesFromCache() async {
    var file = _getDevicesFile();
    if ((await file.exists()) == false) {
      return [];
    }

    var data = await file.readAsString();
    var json = jsonDecode(data);
    var devices = _parseDevices(json);

    return devices;
  }

  @override
  Future<void> saveDevicesToCache(List<GenericDevice> devices) async {
    var file = _getDevicesFile();
    var data = devices.map((e) => e.toJson()).toList();
    var json = jsonEncode(data);

    await file.writeAsString(json);
  }

  @override
  Future<void> deleteDevicesFromCache() async {
    var file = _getDevicesFile();
    if ((await file.exists())) {
      await file.delete();
    }
  }

  File _getDevicesFile() {
    var appDir = AppContext.instance.appDirectory;
    return File(join(appDir, 'devices.json'));
  }

  List<GenericDevice> _parseDevices(List<dynamic> json) {
    var devices = <GenericDevice>[];
    for (var data in json) {
      try {
        var device = GenericDevice.fromJson(data);
        devices.add(device);
      } catch (e) {
        log(data.toString() + e.toString());
      }
    }
    return devices;
  }
}
