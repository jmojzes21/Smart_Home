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
  String secretKey;

  int recentHistoryPeriod;

  int lastWifiIndex;
  List<WifiNetwork> wifiNetworks;

  DeviceConfig({
    required this.hostname,
    required this.deviceName,
    required this.secretKey,
    required this.recentHistoryPeriod,
    required this.lastWifiIndex,
    required this.wifiNetworks,
  });

  void updateWifiNetworks(List<WifiNetwork> networks) {
    String lastWifiName = wifiNetworks[lastWifiIndex].name;
    wifiNetworks = networks;

    WifiNetwork? net = networks.where((e) => e.name == lastWifiName).firstOrNull;
    lastWifiIndex = net != null ? networks.indexOf(net) : -1;
  }

  DeviceConfig clone() {
    return DeviceConfig(
      hostname: hostname,
      deviceName: deviceName,
      secretKey: secretKey,
      recentHistoryPeriod: recentHistoryPeriod,
      lastWifiIndex: lastWifiIndex,
      wifiNetworks: wifiNetworks.map((e) => e.clone()).toList(),
    );
  }

  factory DeviceConfig.fromJson(Map<String, dynamic> json) {
    var wifi = json['wifi'];

    return DeviceConfig(
      hostname: json['hostname'],
      deviceName: json['device_name'],
      secretKey: json['secret_key'],
      recentHistoryPeriod: json['recent_history_period'],
      lastWifiIndex: wifi['last'],
      wifiNetworks: (wifi['networks'] as List<dynamic>).map((e) => WifiNetwork.fromJson(e)).toList(),
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'hostname': hostname,
      'device_name': deviceName,
      'secret_key': secretKey,
      'recent_history_period': recentHistoryPeriod,
      'wifi': {'last': lastWifiIndex, 'networks': wifiNetworks.map((e) => e.toJson()).toList()},
    };
  }
}
