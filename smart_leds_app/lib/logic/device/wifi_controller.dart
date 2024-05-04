import 'package:smart_leds_app/logic/device/device.dart';
import 'package:smart_leds_app/models/misc/wifi_network.dart';

class WifiController {
  // ignore: unused_field
  final Device _device;

  WifiController(this._device);

  Future<List<WifiNetwork>> getNetworks() async => [];

  Future<void> updateNetworks(List<WifiNetwork> networks) async {}
}
