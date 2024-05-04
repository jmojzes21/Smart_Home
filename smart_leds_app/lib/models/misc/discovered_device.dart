import 'dart:io';

class DiscoveredDevice {
  final String name;
  final InternetAddress ipAddress;

  final bool isReal;

  DiscoveredDevice({
    required this.name,
    required this.ipAddress,
  }) : isReal = true;

  DiscoveredDevice.virtual()
      : name = 'Lažni uređaj',
        ipAddress = InternetAddress('0.0.0.0'),
        isReal = false;
}
