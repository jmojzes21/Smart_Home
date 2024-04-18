import 'dart:io';

class DiscoveredDevice {
  final String name;
  final InternetAddress ipAddress;
  final int httpPort;

  final bool isVirtual;

  DiscoveredDevice({
    required this.name,
    required this.ipAddress,
    required this.httpPort,
  }) : isVirtual = false;

  DiscoveredDevice.virtual()
      : name = 'Virtualni uređaj',
        ipAddress = InternetAddress('0.0.0.0'),
        httpPort = 80,
        isVirtual = true;
}
