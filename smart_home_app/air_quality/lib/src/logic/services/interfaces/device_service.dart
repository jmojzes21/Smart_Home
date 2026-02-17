import '../../../models/device_config.dart';
import '../../../models/device_status.dart';

abstract class IDeviceService {
  Future<DeviceStatus> getDeviceStatus();

  Future<DeviceConfig> getDeviceConfig();
  Future<DeviceConfig> updateDeviceConfig(DeviceConfig config);

  Future<DateTime> updateRtcTime(DateTime time);

  Future<DateTime> syncRtcTime() async {
    DateTime time = DateTime.now();
    return updateRtcTime(time);
  }
}
