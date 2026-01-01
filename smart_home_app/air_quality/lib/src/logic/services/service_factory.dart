import '../../models/aq_device.dart';
import 'interfaces/air_quality_service.dart';
import 'virtual/virtual_air_quality_service.dart';
import 'air_quality_service.dart';

class ServiceFactory {
  final AirQualityDevice device;
  late bool _isReal;

  ServiceFactory(this.device) {
    _isReal = device.hostname != '#virtual';
  }

  IAirQualityService getAirQualityService() {
    return _isReal ? AirQualityService(device) : VirtualAirQualityService();
  }
}
