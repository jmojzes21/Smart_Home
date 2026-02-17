import 'package:smart_home_core/exceptions.dart';
import 'package:smart_home_core/view_model.dart';

import '../../models/device_config.dart';
import '../../models/device_status.dart';
import '../services/interfaces/device_service.dart';

class SettingsPageViewModel extends ViewModel {
  final IDeviceService deviceService;
  final Function(String message) onShowMessage;

  bool _isLoading = true;

  DeviceStatus? _deviceStatus;
  DeviceConfig? _deviceConfig;
  DateTime? _currentTime;

  SettingsPageViewModel({required this.deviceService, required this.onShowMessage}) {
    refresh();
  }

  Future<void> refresh() async {
    _isLoading = true;
    notifyListeners();

    try {
      _currentTime = DateTime.now();
      await Future.wait([_getDeviceStatus(), _getDeviceConfig()]);

      notifyListeners();
    } catch (e) {
      String msg = Exceptions.getMessage(e);
      onShowMessage(msg);
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }

  Future<void> syncRtcTime() async {
    _isLoading = true;
    notifyListeners();

    try {
      _currentTime = DateTime.now();
      var rtcTime = await deviceService.syncRtcTime();
      _deviceStatus!.rtcTime = rtcTime;

      String msg = 'Vrijeme je uspješno sinkronizirano.';
      onShowMessage(msg);
    } catch (e) {
      String msg = Exceptions.getMessage(e);
      onShowMessage(msg);
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }

  Future<void> addNetwork(WifiNetwork network) async {
    try {
      _checkNetwork(network);

      var config = _deviceConfig!.clone();

      bool exists = config.wifiNetworks.any((e) => e.name == network.name);
      if (exists) {
        throw AppException('WiFi mreža ${network.name} već postoji!');
      }

      config.wifiNetworks.add(network);
      config.wifiNetworks.sort((a, b) => a.name.compareTo(b.name));

      _isLoading = true;
      notifyListeners();

      var updatedConfig = await deviceService.updateDeviceConfig(config);
      _deviceConfig = updatedConfig;

      onShowMessage("Dodana WiFi mreža ${network.name}.");
    } catch (e) {
      String msg = Exceptions.getMessage(e);
      onShowMessage(msg);
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }

  Future<void> updateNetwork(WifiNetwork network) async {
    try {
      _checkNetwork(network);

      var config = _deviceConfig!.clone();

      WifiNetwork toUpdate = config.wifiNetworks.firstWhere((e) => e.name == network.name);
      toUpdate.password = network.password;

      _isLoading = true;
      notifyListeners();

      var updatedConfig = await deviceService.updateDeviceConfig(config);
      _deviceConfig = updatedConfig;

      onShowMessage("Spremljene promjene WiFi mreže ${network.name}.");
    } catch (e) {
      String msg = Exceptions.getMessage(e);
      onShowMessage(msg);
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }

  Future<void> delete(WifiNetwork network) async {
    try {
      var config = _deviceConfig!.clone();

      config.wifiNetworks.removeWhere((e) => e.name == network.name);

      _isLoading = true;
      notifyListeners();

      var updatedConfig = await deviceService.updateDeviceConfig(config);
      _deviceConfig = updatedConfig;

      onShowMessage("Obrisana WiFi mreža ${network.name}.");
    } catch (e) {
      String msg = Exceptions.getMessage(e);
      onShowMessage(msg);
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }

  void _checkNetwork(WifiNetwork network) {
    if (network.name.isEmpty) {
      throw AppException('Potrebno je unijeti naziv WiFi mreže!');
    }
  }

  Future<void> _getDeviceStatus() async {
    var status = await deviceService.getDeviceStatus();
    _deviceStatus = status;
  }

  Future<void> _getDeviceConfig() async {
    var config = await deviceService.getDeviceConfig();
    _deviceConfig = config;
  }

  bool get isLoading => _isLoading;
  DeviceStatus? get deviceStatus => _deviceStatus;
  DateTime? get currentTime => _currentTime;

  List<WifiNetwork> get wifiNetworks => _deviceConfig!.wifiNetworks;
}
