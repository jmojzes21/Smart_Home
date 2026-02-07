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
      inputVoltage: 4.1,
      memory: MemoryStatus(
        heapSize: 200,
        usedHeap: 50,
        maxUsedHeap: 100,
        psramSize: 4 * 1024,
        usedPsram: 10,
        maxUsedPsram: 100,
      ),
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
