import '../../../models/air_quality.dart';
import '../../../models/aq_history_data.dart';

abstract class IAirQualityService {
  Future<AirQuality> getAirQuality();

  Future<AqHistoryData> getLocalAq();
  Future<void> clearLocalAq();
}
