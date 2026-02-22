import 'dart:math';

import '../../../models/aq_history.dart';
import '../interfaces/air_quality_service.dart';
import '../../../models/air_quality.dart';

class VirtualAirQualityService implements IAirQualityService {
  var random = Random();

  @override
  Future<AirQuality> getAirQuality() async {
    return _getAq();
  }

  @override
  Future<List<AqHistory>> getRecentHistory() async {
    DateTime time = DateTime.now();

    var data = List.generate(10, (index) {
      var aq = _getAq();
      var aqh = AqHistory(
        time: time,
        temperature: _getAqMetrics(aq.temperature, 4),
        humidity: _getAqMetrics(aq.humidity, 10),
        pressure: _getAqMetrics(aq.pressure, 10),
        pm25: _getAqMetrics(aq.pm25.toDouble(), 20),
      );
      time = time.add(Duration(minutes: 1));

      return aqh;
    });

    return data;
  }

  @override
  Future<void> clearRecentHistory() async {}

  AirQuality _getAq() {
    return AirQuality(
      temperature: 10 + 30 * random.nextDouble(),
      humidity: 100 * random.nextDouble(),
      pressure: 990 + 30 * random.nextDouble(),
      pm25: 5 + random.nextInt(95),
    );
  }

  AqMetrics _getAqMetrics(double value, double d) {
    double p1 = random.nextDouble();
    double p2 = random.nextDouble();
    return AqMetrics(average: value, min: value - p1 * d, max: value + p2 * d);
  }
}
