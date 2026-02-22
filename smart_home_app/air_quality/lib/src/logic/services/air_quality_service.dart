import '../../models/aq_chart_data.dart';
import '../../models/aq_history.dart';
import 'interfaces/air_quality_service.dart';
import 'device_client.dart';
import '../../models/air_quality.dart';

class AirQualityService extends IAirQualityService {
  final DeviceClient client;

  AirQualityService(this.client);

  @override
  Future<AirQuality> getAirQuality() async {
    return AirQuality.fromJson(await client.httpGet('/sensor-data'));
  }

  @override
  Future<AqChartData> getRecentHistory() async {
    var json = await client.httpGet('/aq-history');

    var bootTime = DateTime.parse(json['boot_time']);
    var aqHistory = json['aq_history'] as List<dynamic>;

    var data = aqHistory.map((e) => _parseRecentAqHistory(bootTime, e)).toList();
    return AqChartData(data);
  }

  @override
  Future<void> clearRecentHistory() async {
    await client.httpDelete('/aq-history', statusCode: 200);
  }

  AqHistory _parseRecentAqHistory(DateTime bootTime, Map<String, dynamic> json) {
    int timeSeconds = json['time'];
    DateTime time = bootTime.add(Duration(seconds: timeSeconds));

    return AqHistory(
      time: time,
      temperature: AqMetrics.fromJson(json['temperature']),
      humidity: AqMetrics.fromJson(json['humidity']),
      pressure: AqMetrics.fromJson(json['pressure']),
      pm25: AqMetrics.fromJson(json['pm25']),
    );
  }
}
