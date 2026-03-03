import 'package:smart_home_core/device.dart';
import 'package:smart_home_core/exceptions.dart';
import 'package:smart_home_core/handler.dart';

import '../../device_handlers.dart';
import '../../models/generic_device.dart';
import '../services/device_discovery.dart';
import '../services/interfaces/device_service.dart';
import 'package:smart_home_core/view_model.dart';

class DevicesPageViewModel extends ViewModel {
  final IDeviceService deviceService;
  final DeviceDiscovery deviceDiscovery;
  final DeviceHandlers deviceHandlers;
  final Function(String message) onShowMessage;
  final Function(DeviceHandler handler, DeviceContext deviceContext) onDeviceConnected;

  var _devices = <ScannedDevice>[];

  var _isDiscovering = false;
  var _isLoading = true;
  var _isConnecting = false;

  DevicesPageViewModel({
    required this.deviceService,
    required this.deviceDiscovery,
    required this.deviceHandlers,
    required this.onShowMessage,
    required this.onDeviceConnected,
  }) {
    init();
  }

  Future<void> init() async {
    await _getDevicesFromCache();
  }

  Future<void> connectDevice(ScannedDevice device) async {
    var deviceHandler = deviceHandlers.getDeviceHandler(device.type);
    if (deviceHandler == null) {
      return;
    }

    _isConnecting = true;
    notifyListeners();

    try {
      var deviceContext = await deviceHandler.connectDevice(device);
      onDeviceConnected(deviceHandler, deviceContext);
    } catch (e) {
      _isConnecting = false;
      notifyListeners();

      String msg = Exceptions.getMessage(e);
      onShowMessage(msg);
    }
  }

  Future<void> startScan() async {
    if (_isDiscovering) return;

    _isDiscovering = true;
    notifyListeners();

    var stream = deviceDiscovery.start();
    await stream.forEach((device) {
      _onDeviceFound(device);

      if (devices.every((e) => e.availability == Availability.online)) {
        deviceDiscovery.stop();
      }
      notifyListeners();
    });

    _isDiscovering = false;
    for (var device in _devices) {
      if (device.availability == Availability.unknown) {
        device.availability = Availability.offline;
      }
    }

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
      List<ScannedDevice> devices = await deviceService.getDevices();
      await deviceService.saveDevicesToCache(devices);

      devices.addAll(_getVirtualDevices());
      _devices = devices;

      String msg = 'Uređaji su uspješno dohvaćeni.';
      onShowMessage(msg);
    } catch (e) {
      String msg = 'Dohvaćanje uređaji nije uspjelo. ${Exceptions.getMessage(e)}';
      onShowMessage(msg);
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }

  Future<void> _getDevicesFromCache() async {
    _isLoading = true;
    notifyListeners();

    List<ScannedDevice> devices = await deviceService.getDevicesFromCache();
    if (devices.isEmpty) {
      getDevices();
      return;
    }

    devices.addAll(_getVirtualDevices());

    _devices = devices;
    _isLoading = false;
    notifyListeners();
  }

  List<ScannedDevice> _getVirtualDevices() {
    return [ScannedDevice.virtual(name: 'Kvaliteta zraka - virtualni', type: DeviceType.airQuality)];
  }

  void _onDeviceFound(Device newDevice) {
    int index = _devices.indexWhere((e) => e.uuid == newDevice.uuid);
    if (index == -1) return;

    var device = _devices[index];
    device.ipAddress = newDevice.ipAddress;
    device.availability = Availability.online;
  }

  bool get isDiscovering => _isDiscovering;
  bool get isLoading => _isLoading;
  bool get isConnecting => _isConnecting;

  List<ScannedDevice> get devices => _devices;
}
