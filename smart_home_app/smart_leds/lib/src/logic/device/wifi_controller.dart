import 'device.dart';
import '../../models/misc/wifi_network.dart';

class WifiController {
  final DeviceClient _device;

  String ssid = '';
  int rssi = 0;

  WifiController(this._device);

  Future<List<WifiNetwork>> getNetworks() async {
    var json = await _device.getHttp(path: '/wifi_networks');
    var networks = json['networks'] as List<dynamic>;

    return networks.map((e) {
      return WifiNetwork.fromJson(e);
    }).toList();
  }

  Future<void> updateNetworks(List<WifiNetwork> networks) async {
    await _device.postHttp(
      path: '/wifi_networks',
      body: {'networks': networks.map((e) => WifiNetwork.toJson(e)).toList()},
    );
  }
}
