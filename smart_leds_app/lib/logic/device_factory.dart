import 'dart:io';

import 'device/device.dart';
import '../models/misc/discovered_device.dart';
import 'device/real_device.dart';
import 'device/fake_device.dart';
import '../models/misc/session.dart';

class DeviceFactory {
  Device fromDiscovery(DiscoveredDevice device) {
    if (device.isReal) {
      return RealDevice(ipAddress: device.ipAddress);
    } else {
      return VirtualDevice();
    }
  }

  Device fromSession(Session session) {
    if (session.ipAddress == '0.0.0.0') {
      return VirtualDevice();
    }

    var ipAddress = InternetAddress(session.ipAddress);
    return RealDevice(
      ipAddress: ipAddress,
    );
  }
}
