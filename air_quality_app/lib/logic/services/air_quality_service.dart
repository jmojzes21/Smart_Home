import 'package:air_quality_app/models/air_quality.dart';

abstract class IAirQualityService {
  Future<AirQuality> getAirQuality();
}
