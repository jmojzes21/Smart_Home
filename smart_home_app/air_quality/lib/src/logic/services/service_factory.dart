import 'package:smart_home_core/device.dart';

import 'air_quality_service.dart';
import 'mock/mock_air_quality_service.dart';
import 'real/air_quality_service.dart';

class ServiceFactory {
  final Device device;

  ServiceFactory(this.device);

  IAirQualityService getAirQualityService() {
    return device.isReal ? AirQualityService(device) : MockAirQualityService();
  }
}
