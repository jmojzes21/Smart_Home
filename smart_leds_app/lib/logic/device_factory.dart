import '../models/device/device.dart';
import '../models/device/discovered_device.dart';
import '../models/device/real_device.dart';
import '../models/device/virtual_device.dart';

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
