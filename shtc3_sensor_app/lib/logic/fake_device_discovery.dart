import 'package:shtc3_sensor_app/logic/device_controller.dart';
import 'package:shtc3_sensor_app/logic/device_discovery.dart';
import 'package:shtc3_sensor_app/logic/fake_device_controller.dart';

class FakeDeviceDiscovery extends DeviceDiscovery {
  @override
  Future<List<DeviceController>> getBondedDevices() {
    return Future.delayed(Duration(milliseconds: 500), () {
      return [FakeDeviceController("SHTC3 senzor temperature")];
    });
  }
}
