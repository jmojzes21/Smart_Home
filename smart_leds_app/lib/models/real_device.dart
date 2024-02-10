import 'package:http/http.dart';
import 'package:smart_leds_app/models/device_info.dart';

import 'device.dart';

class RealDevice extends Device {
  int httpPort;

  RealDevice({
    required super.name,
    required super.ipAddress,
    required this.httpPort,
  });

  @override
  Future<DeviceInfo> getDeviceInfo() {
    // TODO: implement getDeviceInfo
    throw UnimplementedError();
  }
}
