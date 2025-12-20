import '../../models/air_quality.dart';

abstract class IAirQualityService {
  Future<AirQuality> getAirQuality();
}
