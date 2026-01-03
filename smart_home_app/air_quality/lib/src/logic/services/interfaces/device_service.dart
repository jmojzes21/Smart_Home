import '../../../models/device_status.dart';

abstract class IDeviceService {
  Future<DeviceStatus> getDeviceStatus();

  Future<DateTime> getRtcTime();
  Future<DateTime> setRtcTime(DateTime time);

  Future<DateTime> syncRtcTime() async {
    DateTime time = DateTime.now();
    return setRtcTime(time);
  }
}
