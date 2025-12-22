import 'package:smart_home_core/device.dart';

import '../../models/generic_device.dart';
import '../services/device_discovery.dart';
import '../services/interfaces/device_service.dart';
import 'package:smart_home_core/view_model.dart';

class DevicesPageViewModel extends ViewModel {
  final IDeviceService deviceService;
  final DeviceDiscovery deviceDiscovery;

  var _devices = <GenericDevice>[];

  var _isDiscovering = false;
  var _isLoading = true;

  DevicesPageViewModel({required this.deviceService, required this.deviceDiscovery}) {
    _getDevices();
  }

  Future<void> startScan() async {
    if (_isDiscovering) return;

    _isDiscovering = true;
    notifyListeners();

    var stream = deviceDiscovery.start();
    await stream.forEach((device) {
      _onDeviceFound(device);
      notifyListeners();
    });

    _isDiscovering = false;
    notifyListeners();
  }

  void stopScan() {
    if (!isDiscovering) return;
    deviceDiscovery.stop();
  }

  Future<void> _getDevices() async {
    _isLoading = true;
    notifyListeners();

    _devices = await deviceService.getDevices();
    _isLoading = false;
    notifyListeners();
  }

  void _onDeviceFound(Device newDevice) {
    int index = _devices.indexWhere((e) => e.domain == newDevice.domain && e.type == newDevice.type);
    if (index != -1) {
      var device = _devices[index];
      _devices[index] = GenericDevice(
        name: device.name,
        domain: device.domain,
        type: device.type,
        ipAddress: newDevice.ipAddress,
        macAddress: newDevice.macAddress,
        isOnline: true,
      );
    }
  }

  bool get isDiscovering => _isDiscovering;
  bool get isLoading => _isLoading;

  List<GenericDevice> get devices => _devices;
}
