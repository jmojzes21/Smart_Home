class WifiNetwork {
  String ssid = '';
  String password = '';

  WifiNetwork(this.ssid, this.password);

  WifiNetwork copy() => WifiNetwork(ssid, password);

  factory WifiNetwork.fromJson(Map<String, dynamic> src) {
    return WifiNetwork(src['ssid'], src['pass']);
  }

  static Map<String, dynamic> toJson(WifiNetwork network) {
    return {
      'ssid': network.ssid,
      'pass': network.password,
    };
  }
}
