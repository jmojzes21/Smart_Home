import '../models/device.dart';
import '../models/discovered_device.dart';
import '../models/real_device.dart';
import '../models/virtual_device.dart';

class DeviceFactory {
  Device createDevice(DiscoveredDevice device) {
    if (device.isVirtual) {
      return VirtualDevice(
        name: device.name,
        ipAddress: device.ipAddress,
      );
    }

    return RealDevice(
      name: device.name,
      ipAddress: device.ipAddress,
      httpPort: device.httpPort,
    );
  }
}
