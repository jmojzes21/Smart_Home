import 'package:smart_home_core/exceptions.dart';
import 'package:smart_home_core/view_model.dart';

import '../../models/device_status.dart';
import '../services/interfaces/device_service.dart';

class SettingsPageViewModel extends ViewModel {
  final IDeviceService deviceService;
  final Function(String message) onException;

  bool _isLoading = true;

  DeviceStatus? _deviceStatus;
  double _voltage = 0;
  double _heapSize = 0;
  double _usedHeap = 0;
  double _freeHeap = 0;
  double _maxUsedHeap = 0;

  double _usedHeapPercent = 0;
  double _freeHeapPercent = 0;
  double _maxUsedHeapPercent = 0;

  SettingsPageViewModel({required this.deviceService, required this.onException}) {
    getDeviceStatus();
  }

  Future<void> getDeviceStatus() async {
    _isLoading = true;
    notifyListeners();

    try {
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

      notifyListeners();
    } catch (e) {
      String msg = Exceptions.getMessage(e);
      onException(msg);
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }

  bool get isLoading => _isLoading;
  DeviceStatus? get deviceStatus => _deviceStatus;
  double get voltage => _voltage;
  double get heapSize => _heapSize;
  double get usedHeap => _usedHeap;
  double get freeHeap => _freeHeap;
  double get maxUsedHeap => _maxUsedHeap;
  double get usedHeapPercent => _usedHeapPercent;
  double get freeHeapPercent => _freeHeapPercent;
  double get maxUsedHeapPercent => _maxUsedHeapPercent;
}
