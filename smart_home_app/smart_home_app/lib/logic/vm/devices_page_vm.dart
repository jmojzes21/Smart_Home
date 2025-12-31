import 'package:smart_home_core/device.dart';
import 'package:smart_home_core/exceptions.dart';

import '../../models/generic_device.dart';
import '../services/device_discovery.dart';
import '../services/interfaces/device_service.dart';
import 'package:smart_home_core/view_model.dart';

class DevicesPageViewModel extends ViewModel {
  final IDeviceService deviceService;
  final DeviceDiscovery deviceDiscovery;
  final Function(String message) onShowMessage;

  var _devices = <GenericDevice>[];

  var _isDiscovering = false;
  var _isLoading = true;

  DevicesPageViewModel({required this.deviceService, required this.deviceDiscovery, required this.onShowMessage}) {
    _getDevicesFromCache();
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

  Future<void> getDevices() async {
    _isLoading = true;
    notifyListeners();

    try {
      List<GenericDevice> devices = await deviceService.getDevices();
      await deviceService.saveDevicesToCache(devices);

      devices.addAll(_getVirtualDevices());

      _devices = devices;
      _isLoading = false;
      notifyListeners();
    } catch (e) {
      _isLoading = false;
      notifyListeners();

      String msg = 'Dohvaćanje uređaji nije uspjelo. ${Exceptions.getMessage(e)}';
      onShowMessage(msg);
    }
  }

  Future<void> _getDevicesFromCache() async {
    _isLoading = true;
    notifyListeners();

    List<GenericDevice> devices = await deviceService.getDevicesFromCache();
    devices.addAll(_getVirtualDevices());

    _devices = devices;
    _isLoading = false;
    notifyListeners();
  }

  List<GenericDevice> _getVirtualDevices() {
    //  var virtualService = VirtualDeviceService();
    //    devices.addAll(await virtualService.getDevicesFromCache());
    return [];
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
