import '../../../models/air_quality.dart';
import '../../../models/aq_history.dart';

abstract class IAirQualityService {
  Future<AirQuality> getAirQuality();

  Future<List<AqHistory>> getRecentHistory();
  Future<void> clearRecentHistory();
}
