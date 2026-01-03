import 'device_client.dart';
import 'device_service.dart';
import 'interfaces/air_quality_service.dart';
import 'interfaces/device_service.dart';
import 'virtual/virtual_air_quality_service.dart';
import 'air_quality_service.dart';
import 'virtual/virtual_device_service.dart';

class ServiceFactory {
  final DeviceClient client;
  late bool _isReal;

  ServiceFactory(this.client) {
    _isReal = client.device.hostname != '#virtual';
  }

  IDeviceService getDeviceService() {
    return _isReal ? DeviceService(client) : VirtualDeviceService(client.device);
  }

  IAirQualityService getAirQualityService() {
    return _isReal ? AirQualityService(client) : VirtualAirQualityService();
  }
}
