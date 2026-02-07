import 'package:smart_home_core/exceptions.dart';
import 'package:smart_home_core/view_model.dart';

import '../../models/device_status.dart';
import '../services/interfaces/device_service.dart';

class SettingsPageViewModel extends ViewModel {
  final IDeviceService deviceService;
  final Function(String message) onShowMessage;

  bool _isLoading = true;

  DeviceStatus? _deviceStatus;
  DateTime? _rtcTime;
  DateTime? _currentTime;

  SettingsPageViewModel({required this.deviceService, required this.onShowMessage}) {
    refresh();
  }

  Future<void> refresh() async {
    _isLoading = true;
    notifyListeners();

    try {
      await Future.wait([_getDeviceStatus(), _getRtcTime()]);

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
      var rtcTime = await deviceService.syncRtcTime();
      _rtcTime = rtcTime;

      notifyListeners();
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

  Future<void> _getDeviceStatus() async {
    var status = await deviceService.getDeviceStatus();
    _deviceStatus = status;
  }

  Future<void> _getRtcTime() async {
    var rtcTime = await deviceService.getRtcTime();
    _rtcTime = rtcTime;
    _currentTime = DateTime.now();
  }

  bool get isLoading => _isLoading;
  DeviceStatus? get deviceStatus => _deviceStatus;
  DateTime? get rtcTime => _rtcTime;
  DateTime? get currentTime => _currentTime;
}
