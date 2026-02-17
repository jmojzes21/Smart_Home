import '../../models/device_config.dart';
import '../../models/device_status.dart';
import 'device_client.dart';
import 'interfaces/device_service.dart';

class DeviceService extends IDeviceService {
  final DeviceClient client;

  DeviceService(this.client);

  @override
  Future<DeviceStatus> getDeviceStatus() async {
    var json = await client.httpGet('/device-status', {'ram_usage': 'true', 'input_voltage': 'true'});
    return DeviceStatus.fromJson(json);
  }

  @override
  Future<DeviceConfig> getDeviceConfig() async {
    var json = await client.httpGet('/config');
    return DeviceConfig.fromJson(json);
  }

  @override
  Future<DeviceConfig> updateDeviceConfig(DeviceConfig config) async {
    var json = await client.httpPatch('/config', config.toJson());
    return DeviceConfig.fromJson(json);
  }

  @override
  Future<DateTime> updateRtcTime(DateTime time) async {
    var json = await client.httpPost('/sync-time', {
      'week_day': time.weekday,
      'month_day': time.day,
      'month': time.month,
      'year': time.year,
      'hour': time.hour,
      'minute': time.minute,
      'second': time.second,
    });
    String dtText = json['date_time'];

    return DateTime.parse(dtText);
  }
}
