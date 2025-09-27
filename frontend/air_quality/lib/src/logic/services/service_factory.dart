import 'air_quality_service.dart';
import 'mock/mock_air_quality_service.dart';
import 'real/air_quality_service.dart';

class ServiceFactory {
  static final bool _useRealServices = true;

  static IAirQualityService getAirQualityService() {
    return _useRealServices ? AirQualityService() : MockAirQualityService();
  }
}
