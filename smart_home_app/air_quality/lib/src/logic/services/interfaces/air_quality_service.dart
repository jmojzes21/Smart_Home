import '../../../models/air_quality.dart';
import '../../../models/aq_chart_data.dart';

abstract class IAirQualityService {
  Future<AirQuality> getAirQuality();

  Future<AqChartData> getRecentHistory();
  Future<void> clearRecentHistory();
}
