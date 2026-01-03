import '../../models/device_status.dart';
import 'device_client.dart';
import 'interfaces/device_service.dart';

class DeviceService extends IDeviceService {
  final DeviceClient client;

  DeviceService(this.client);

  @override
  Future<DeviceStatus> getDeviceStatus() async {
    var json = await client.httpGet('/device', {'ram_usage': 'true', 'input_voltage': 'true'});
    return DeviceStatus.fromJson(json);
  }
}
