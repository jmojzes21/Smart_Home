import 'dart:io';

class DiscoveredDevice {
  final String name;
  final InternetAddress ipAddress;
  final bool isVirtual;

  DiscoveredDevice({
    required this.name,
    required this.ipAddress,
  }) : isVirtual = false;

  DiscoveredDevice.virtual()
      : name = 'Virtualni uređaj',
        ipAddress = InternetAddress('0.0.0.0'),
        isVirtual = true;
}
