import 'package:air_quality/src/models/air_quality.dart';

abstract class IAirQualityService {
  Future<AirQuality> getAirQuality();
}
