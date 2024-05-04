import 'package:smart_leds_app/logic/device/device.dart';
import 'package:smart_leds_app/models/misc/power_sensor_data.dart';

class PowerSensor {
  // ignore: unused_field
  final Device _device;

  PowerSensor(this._device);

  Future<void> setState(bool active) async {}

  Future<PowerSensorData> getData() => throw UnimplementedError();
}
