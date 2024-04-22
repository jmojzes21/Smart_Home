import '../models/device/device.dart';
import '../models/device/discovered_device.dart';
import '../models/device/real_device.dart';
import '../models/device/fake_device.dart';

class DeviceFactory {
  Device createDevice(DiscoveredDevice device) {
    if (device.isReal) {
      return RealDevice(ipAddress: device.ipAddress);
    } else {
      return VirtualDevice();
    }
  }
}
