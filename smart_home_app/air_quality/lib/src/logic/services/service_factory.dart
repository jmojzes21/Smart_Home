import 'package:smart_home_core/device.dart';

import 'air_quality_service.dart';
import 'mock/mock_air_quality_service.dart';
import 'real/air_quality_service.dart';

class ServiceFactory {
  final Device device;
  late bool _isReal;

  ServiceFactory(this.device) {
    _isReal = device.hostname != '#virtual';
  }

  IAirQualityService getAirQualityService() {
    return _isReal ? AirQualityService(device) : MockAirQualityService();
  }
}
