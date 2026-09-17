import 'package:smart_home_core/models.dart';

import '../../models/generic_device.dart';
import 'interfaces/device_service.dart';

class DeviceService implements IDeviceService {
  @override
  Future<List<ScannedDevice>> getDevices() async {
    return [
      ScannedDevice(
        type: DeviceType.airQuality,
        name: 'Kvaliteta zraka',
        hostname: 'air-quality-station.local',
        uuid: '',
      ),
    ];

    /*var username = AppContext.instance.currentUser.username;

    var client = BackendClient();
    var response = await client.httpGet('/api/users/$username/devices');

    var devices = _parseDevices(response);
    devices.sort((a, b) => a.name.compareTo(b.name));

    return devices;*/
  }

  @override
  Future<List<ScannedDevice>> getDevicesFromCache() async {
    return [];
    /*var file = _getDevicesFile();
    if ((await file.exists()) == false) {
      return [];
    }

    var data = await file.readAsString();
    var json = jsonDecode(data);
    var devices = _parseDevices(json);

    return devices;*/
  }

  @override
  Future<void> saveDevicesToCache(List<ScannedDevice> devices) async {
    /*var file = _getDevicesFile();
    var data = devices.map((e) => e.toJson()).toList();
    var json = jsonEncode(data);

    await file.writeAsString(json);*/
  }

  @override
  Future<void> deleteDevicesFromCache() async {
    /*var file = _getDevicesFile();
    if ((await file.exists())) {
      await file.delete();
    }*/
  }

  /*
  File _getDevicesFile() {
    var appDir = AppContext.instance.appDirectory;
    return File(join(appDir, 'devices.json'));
  }

  List<ScannedDevice> _parseDevices(List<dynamic> json) {
    var devices = <ScannedDevice>[];
    for (var data in json) {
      try {
        var device = ScannedDevice.fromJson(data);
        devices.add(device);
      } catch (e) {
        log(data.toString() + e.toString());
      }
    }
    return devices;
  }*/
}
