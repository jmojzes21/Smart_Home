import '../../../models/air_quality.dart';
import '../../../models/aq_history.dart';

abstract class IAirQualityService {
  Future<AirQuality> getAirQuality();

  Future<void> startLiveData();
  void stopLiveData();
  Stream<AirQuality> getLiveDataStream();

  Future<List<AqHistory>> getRecentHistory();
  Future<void> clearRecentHistory();
}
