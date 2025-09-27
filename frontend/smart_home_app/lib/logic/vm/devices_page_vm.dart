import 'package:smart_home_core/view_model.dart';

class DevicesPageViewModel extends ViewModel {
  var discoveredDevices = <String>[];
  var isDiscovering = false;

  void startScan() async {
    isDiscovering = true;
    discoveredDevices.clear();
    notifyListeners();
  }

  void stopScan() async {
    isDiscovering = false;
    notifyListeners();
  }
}
