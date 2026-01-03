import '../../../models/aq_device.dart';
import '../../../models/device_status.dart';
import '../interfaces/device_service.dart';

class VirtualDeviceService extends IDeviceService {
  final AqDevice device;

  VirtualDeviceService(this.device);

  @override
  Future<DeviceStatus> getDeviceStatus() async {
    return DeviceStatus(
      name: device.name,
      hostname: device.hostname,
      version: 'v1.0.0',
      ipAddress: '192.168.1.1',
      ssid: 'wifi1',
      rssi: -20,
      heapSize: 200 * 1024,
      freeHeap: 150 * 1024,
      minFreeHeap: 100 * 1024,
      inputVoltage: 5000,
    );
  }

  @override
  Future<DateTime> getRtcTime() async {
    return DateTime.now();
  }

  @override
  Future<DateTime> setRtcTime(DateTime time) async {
    return DateTime.now();
  }
}
