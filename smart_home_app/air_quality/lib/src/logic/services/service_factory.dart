import 'device_client.dart';
import 'interfaces/air_quality_service.dart';
import 'virtual/virtual_air_quality_service.dart';
import 'air_quality_service.dart';

class ServiceFactory {
  final DeviceClient client;
  late bool _isReal;

  ServiceFactory(this.client) {
    _isReal = client.device.hostname != '#virtual';
  }

  IAirQualityService getAirQualityService() {
    return _isReal ? AirQualityService(client) : VirtualAirQualityService();
  }
}
