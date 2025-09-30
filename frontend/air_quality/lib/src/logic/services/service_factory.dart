import 'package:smart_home_core/models.dart';

import 'air_quality_service.dart';
import 'mock/mock_air_quality_service.dart';
import 'real/air_quality_service.dart';

class ServiceFactory {
  final Device device;
  late final bool _useRealServices;

  ServiceFactory(this.device) {
    _useRealServices = device.ipAddress != null;
  }

  IAirQualityService getAirQualityService() {
    return _useRealServices ? AirQualityService(device) : MockAirQualityService();
  }
}
