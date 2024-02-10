import '../models/device.dart';
import '../models/discovered_device.dart';
import '../models/real_device.dart';
import '../models/virtual_device.dart';

class DeviceFactory {
  Device createDevice(DiscoveredDevice discoveredDevice) {
    if (discoveredDevice.isVirtual) {
      return VirtualDevice();
    }

    return RealDevice();
  }
}
