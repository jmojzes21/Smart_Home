import 'package:smart_leds_app/logic/device/device.dart';
import 'package:smart_leds_app/models/misc/wifi_network.dart';

class WifiController {
  final Device _device;

  WifiController(this._device);

  Future<List<WifiNetwork>> getNetworks() async {
    var json = await _device.getHttp(path: '/wifi_networks');
    var networks = json['networks'] as List<dynamic>;

    return networks.map((e) {
      return WifiNetwork.fromJson(e);
    }).toList();
  }

  Future<void> updateNetworks(List<WifiNetwork> networks) async {
    await _device.postHttp(path: '/wifi_networks', body: {
      'networks': networks.map((e) => WifiNetwork.toJson(e)).toList(),
    });
  }
}
