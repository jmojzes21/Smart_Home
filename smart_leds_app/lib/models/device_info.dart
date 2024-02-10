class DeviceInfo {
  String name;
  String firmwareVersion;
  String ipAddress;
  String macAddress;
  String wifiSSID;
  int wifiRSSI;

  DeviceInfo({
    required this.name,
    required this.firmwareVersion,
    required this.ipAddress,
    required this.macAddress,
    required this.wifiSSID,
    required this.wifiRSSI,
  });

  factory DeviceInfo.fromJson(Map<String, dynamic> src) {
    return DeviceInfo(
      name: src['name'],
      firmwareVersion: src['version'],
      ipAddress: src['ip'],
      macAddress: src['mac'],
      wifiSSID: src['ssid'],
      wifiRSSI: src['rssi'],
    );
  }
}
