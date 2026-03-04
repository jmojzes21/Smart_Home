import 'package:flutter/widgets.dart';
import 'package:smart_home_core/exceptions.dart';
import 'package:smart_home_core/view_model.dart';

import '../../models/device_config.dart';
import '../../models/device_status.dart';
import '../services/interfaces/device_service.dart';

class AdvancedPageViewModel extends ViewModel {
  final IDeviceService deviceService;
  final Function(String message) onShowMessage;

  final _tecBackendAddr = TextEditingController();

  bool _isLoading = true;
  bool _shouldSaveChanges = false;

  DeviceStatus? _deviceStatus;
  DeviceConfig? _deviceConfig;
  DateTime? _currentTime;

  AdvancedPageViewModel({required this.deviceService, required this.onShowMessage}) {
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

  void addNetwork(WifiNetwork network, VoidCallback onSuccess) {
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

  void updateNetwork(WifiNetwork network, VoidCallback onSuccess) {
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

  void deleteNetwork(WifiNetwork network, VoidCallback onSuccess) {
    try {
      wifiNetworks.removeWhere((e) => e.name == network.name);

      _shouldSaveChanges = true;
      onShowMessage("Obrisana WiFi mreža ${network.name}.");
      onSuccess();
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
    _deviceConfig!.recentPeriod = value;
    _shouldSaveChanges = true;
    notifyListeners();
  }

  void updateHistoryPeriod(int value) {
    _deviceConfig!.historyPeriod = value;
    _shouldSaveChanges = true;
    notifyListeners();
  }

  Future<void> updateSendAirQualityHistory(bool value) async {
    _isLoading = true;
    notifyListeners();

    try {
      bool result = await deviceService.updateSendAirQualityHistory(value);
      deviceStatus!.sendAqHistory = result;
    } catch (e) {
      String msg = Exceptions.getMessage(e);
      onShowMessage(msg);
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }

  void onUpdatedBackendAddress(String value) {
    bool shouldSave = value != _deviceConfig!.backendAddress;

    if (shouldSave != _shouldSaveChanges) {
      _shouldSaveChanges = shouldSave;
      notifyListeners();
    }
  }

  Future<void> updateSettings() async {
    _isLoading = true;
    notifyListeners();

    try {
      String backendAddr = _tecBackendAddr.text.trim();
      _deviceConfig!.backendAddress = backendAddr;

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

  Future<void> restartDevice() async {
    _isLoading = true;
    notifyListeners();

    try {
      await deviceService.restartDevice();
      onShowMessage("Uređaj se ponovno pokreće.");
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
    _tecBackendAddr.text = config.backendAddress;
  }

  bool get isLoading => _isLoading;
  bool get shouldSaveChanges => _shouldSaveChanges;

  DeviceStatus? get deviceStatus => _deviceStatus;
  DeviceConfig? get deviceConfig => _deviceConfig;
  DateTime? get currentTime => _currentTime;

  TextEditingController get tecBackendAddr => _tecBackendAddr;
  List<WifiNetwork> get wifiNetworks => _deviceConfig!.wifiNetworks;

  @override
  void dispose() {
    _tecBackendAddr.dispose();
    super.dispose();
  }
}
