import 'dart:convert';
import 'dart:io';

import 'package:path/path.dart';
import 'package:smart_home_core/device.dart';

import '../../models/generic_device.dart';
import '../misc/app_context.dart';
import 'interfaces/device_service.dart';
import 'virtual/virtual_device_service.dart';

class DeviceService implements IDeviceService {
  @override
  Future<List<GenericDevice>> getDevices() async {
    var appDir = await AppContext.getAppDirectory();
    var path = join(appDir, 'devices.json');
    var file = File(path);

    if ((await file.exists()) == false) {
      return [];
    }

    var data = await file.readAsString();
    var json = jsonDecode(data);
    var devices = _parseDevices(json);

    var virtualService = VirtualDeviceService();
    devices.addAll(await virtualService.getDevices());

    return devices;
  }

  List<GenericDevice> _parseDevices(dynamic json) {
    return (json as List<dynamic>).map((e) => _parseDevice(e)).toList();
  }

  GenericDevice _parseDevice(dynamic json) {
    return GenericDevice(type: DeviceType.parse(json['type']), name: json['name'], domain: json['domain']);
  }
}
