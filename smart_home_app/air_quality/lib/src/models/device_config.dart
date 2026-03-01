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

  int recentHistoryPeriod;

  List<WifiNetwork> wifiNetworks;

  DeviceConfig({
    required this.hostname,
    required this.deviceName,
    required this.recentHistoryPeriod,
    required this.wifiNetworks,
  });

  void updateWifiNetworks(List<WifiNetwork> networks) {
    wifiNetworks = networks;
  }

  DeviceConfig clone() {
    return DeviceConfig(
      hostname: hostname,
      deviceName: deviceName,
      recentHistoryPeriod: recentHistoryPeriod,
      wifiNetworks: wifiNetworks.map((e) => e.clone()).toList(),
    );
  }

  factory DeviceConfig.fromJson(Map<String, dynamic> json) {
    return DeviceConfig(
      hostname: json['hostname'],
      deviceName: json['device_name'],
      recentHistoryPeriod: json['recent_history_period'],
      wifiNetworks: (json['wifi_networks'] as List<dynamic>).map((e) => WifiNetwork.fromJson(e)).toList(),
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'hostname': hostname,
      'device_name': deviceName,
      'recent_history_period': recentHistoryPeriod,
      'wifi_networks': wifiNetworks.map((e) => e.toJson()).toList(),
    };
  }
}
