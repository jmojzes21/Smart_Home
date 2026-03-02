class WifiNetwork {
  String name;
  String password;

  WifiNetwork({required this.name, required this.password});

  factory WifiNetwork.fromJson(Map<String, dynamic> json) {
    return WifiNetwork(name: json['ssid'], password: json['password']);
  }

  Map<String, dynamic> toJson() {
    return {'ssid': name, 'password': password};
  }

  WifiNetwork clone() {
    return WifiNetwork(name: name, password: password);
  }
}

class DeviceConfig {
  String hostname;
  String deviceName;

  String deviceUuid;
  String backendAddress;

  /// Recent period in seconds
  int recentPeriod;

  // History period for sending data to backend in seconds
  int historyPeriod;

  List<WifiNetwork> wifiNetworks;

  DeviceConfig({
    required this.hostname,
    required this.deviceName,
    required this.deviceUuid,
    required this.backendAddress,
    required this.recentPeriod,
    required this.historyPeriod,
    required this.wifiNetworks,
  });

  void updateWifiNetworks(List<WifiNetwork> networks) {
    wifiNetworks = networks;
  }

  DeviceConfig clone() {
    return DeviceConfig(
      hostname: hostname,
      deviceName: deviceName,
      deviceUuid: deviceUuid,
      backendAddress: backendAddress,
      recentPeriod: recentPeriod,
      historyPeriod: historyPeriod,
      wifiNetworks: wifiNetworks.map((e) => e.clone()).toList(),
    );
  }

  factory DeviceConfig.fromJson(Map<String, dynamic> json) {
    return DeviceConfig(
      hostname: json['hostname'],
      deviceName: json['device_name'],
      deviceUuid: json['device_uuid'],
      backendAddress: json['backend_addr'],
      recentPeriod: json['recent_data_period'],
      historyPeriod: json['history_data_period'],
      wifiNetworks: (json['wifi_networks'] as List<dynamic>).map((e) => WifiNetwork.fromJson(e)).toList(),
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'hostname': hostname,
      'device_name': deviceName,
      'device_uuid': deviceUuid,
      'backend_addr': backendAddress,
      'recent_data_period': recentPeriod,
      'history_data_period': historyPeriod,
      'wifi_networks': wifiNetworks.map((e) => e.toJson()).toList(),
    };
  }
}
