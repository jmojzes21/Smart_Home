import 'package:flutter/widgets.dart';
import 'package:smart_home_core/exceptions.dart';
import 'package:smart_home_core/view_model.dart';

import '../../models/device_config.dart';
import '../../models/device_status.dart';
import '../services/interfaces/device_service.dart';

class SettingsPageViewModel extends ViewModel {
  final IDeviceService deviceService;
  final Function(String message) onShowMessage;

  bool _isLoading = true;
  bool _shouldSaveChanges = false;

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

      _shouldSaveChanges = false;
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

  Future<void> addNetwork(WifiNetwork network, VoidCallback onSuccess) async {
    try {
      _checkNetwork(network);

      bool exists = wifiNetworks.any((e) => e.name == network.name);
      if (exists) {
        throw AppException('WiFi mreža ${network.name} već postoji!');
      }

      wifiNetworks.add(network);
      wifiNetworks.sort((a, b) => a.name.compareTo(b.name));

      _shouldSaveChanges = true;
      onSuccess();
    } catch (e) {
      String msg = Exceptions.getMessage(e);
      onShowMessage(msg);
    } finally {
      notifyListeners();
    }
  }

  Future<void> updateNetwork(WifiNetwork network, VoidCallback onSuccess) async {
    try {
      _checkNetwork(network);

      WifiNetwork toUpdate = wifiNetworks.firstWhere((e) => e.name == network.name);
      toUpdate.password = network.password;

      _shouldSaveChanges = true;
      onSuccess();
    } catch (e) {
      String msg = Exceptions.getMessage(e);
      onShowMessage(msg);
    } finally {
      notifyListeners();
    }
  }

  Future<void> delete(WifiNetwork network) async {
    try {
      wifiNetworks.removeWhere((e) => e.name == network.name);

      _shouldSaveChanges = true;
      onShowMessage("Obrisana WiFi mreža ${network.name}.");
    } catch (e) {
      String msg = Exceptions.getMessage(e);
      onShowMessage(msg);
    } finally {
      notifyListeners();
    }
  }

  void _checkNetwork(WifiNetwork network) {
    if (network.name.isEmpty) {
      throw AppException('Potrebno je unijeti naziv WiFi mreže!');
    }
  }

  void updateRecentPeriod(int value) {
    _deviceConfig!.recentHistoryPeriod = value;
    _shouldSaveChanges = true;
    notifyListeners();
  }

  Future<void> updateSettings() async {
    try {
      var updatedConfig = await deviceService.updateDeviceConfig(_deviceConfig!);
      _deviceConfig = updatedConfig;

      _shouldSaveChanges = false;
      onShowMessage("Promjene su uspješno spremljene.");
    } catch (e) {
      String msg = Exceptions.getMessage(e);
      onShowMessage(msg);
    } finally {
      _isLoading = false;
      notifyListeners();
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
  bool get shouldSaveChanges => _shouldSaveChanges;

  DeviceStatus? get deviceStatus => _deviceStatus;
  DeviceConfig? get deviceConfig => _deviceConfig;
  DateTime? get currentTime => _currentTime;

  List<WifiNetwork> get wifiNetworks => _deviceConfig!.wifiNetworks;
}
