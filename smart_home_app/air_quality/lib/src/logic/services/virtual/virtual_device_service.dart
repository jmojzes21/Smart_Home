import '../../../models/aq_device.dart';
import '../../../models/device_config.dart';
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
      rtcTime: DateTime.now(),
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
  Future<DeviceConfig> getDeviceConfig() async {
    return DeviceConfig(
      hostname: device.hostname,
      deviceName: device.name,
      deviceUuid: '',
      backendAddress: 'localhost:8080',
      recentPeriod: 60,
      historyPeriod: 300,
      wifiNetworks: [
        WifiNetwork(name: 'wifi1', password: 'wifi1'),
        WifiNetwork(name: 'wifi2', password: 'wifi2'),
        WifiNetwork(name: 'wifi3', password: 'wifi3'),
      ],
    );
  }

  @override
  Future<DeviceConfig> updateDeviceConfig(DeviceConfig config) async {
    return config;
  }

  @override
  Future<DateTime> updateRtcTime(DateTime time) async {
    return DateTime.now();
  }

  @override
  Future<void> restartDevice() async {}
}
