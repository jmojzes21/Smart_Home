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

  double _voltage = 0;
  double _heapSize = 0;
  double _usedHeap = 0;
  double _freeHeap = 0;
  double _maxUsedHeap = 0;

  double _usedHeapPercent = 0;
  double _freeHeapPercent = 0;
  double _maxUsedHeapPercent = 0;

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
    _voltage = status.getVoltageInVolts();
    _heapSize = status.getHeapSizeKB();
    _usedHeap = status.getUsedHeapKB();
    _freeHeap = status.getFreeHeapKB();
    _maxUsedHeap = status.getMaxUsedHeapKB();

    _usedHeapPercent = (_usedHeap / _heapSize) * 100.0;
    _freeHeapPercent = (_freeHeap / _heapSize) * 100.0;
    _maxUsedHeapPercent = (_maxUsedHeap / _heapSize) * 100.0;
  }

  Future<void> _getRtcTime() async {
    var rtcTime = await deviceService.getRtcTime();
    _rtcTime = rtcTime;
  }

  bool get isLoading => _isLoading;
  DeviceStatus? get deviceStatus => _deviceStatus;
  DateTime? get rtcTime => _rtcTime;

  double get voltage => _voltage;
  double get heapSize => _heapSize;
  double get usedHeap => _usedHeap;
  double get freeHeap => _freeHeap;
  double get maxUsedHeap => _maxUsedHeap;
  double get usedHeapPercent => _usedHeapPercent;
  double get freeHeapPercent => _freeHeapPercent;
  double get maxUsedHeapPercent => _maxUsedHeapPercent;
}
