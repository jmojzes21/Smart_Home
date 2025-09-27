import 'package:smart_home_app/logic/services/device_discovery.dart';
import 'package:smart_home_core/models.dart';
import 'package:smart_home_core/view_model.dart';

class DevicesPageViewModel extends ViewModel {
  final _deviceDiscovery = DeviceDiscovery();

  final _discoveredDevices = <Device>[];
  var _isDiscovering = false;

  Future<void> startScan() async {
    if (_isDiscovering) return;

    _isDiscovering = true;
    _discoveredDevices.clear();
    notifyListeners();

    var stream = _deviceDiscovery.start();
    await stream.forEach((device) {
      _discoveredDevices.add(device);
      notifyListeners();
    });

    _isDiscovering = false;
    notifyListeners();
  }

  void stopScan() {
    if (!isDiscovering) return;
    _deviceDiscovery.stop();
  }

  bool get isDiscovering => _isDiscovering;
  List<Device> get discoveredDevices => _discoveredDevices;
}
