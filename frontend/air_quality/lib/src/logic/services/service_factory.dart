import 'package:air_quality/src/logic/services/air_quality_service.dart';
import 'package:air_quality/src/logic/services/mock/mock_air_quality_service.dart';
import 'package:air_quality/src/logic/services/real/air_quality_service.dart';

class ServiceFactory {
  static final bool _useRealServices = true;

  static IAirQualityService getAirQualityService() {
    return _useRealServices ? AirQualityService() : MockAirQualityService();
  }
}
