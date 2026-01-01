import 'device.dart';
import '../../models/misc/power_sensor_data.dart';

class PowerSensor {
  final DeviceClient _device;

  PowerSensor(this._device);

  Future<void> setState(bool active) async {
    await _device.postHttp(path: '/power_sensor', body: {'active': active});
  }

  Future<PowerSensorData> getData() async {
    var json = await _device.getHttp(path: '/power_sensor');
    return PowerSensorData.fromJson(json);
  }
}
