import 'dart:math';

import '../../../models/aq_history.dart';
import '../../../models/aq_history_data.dart';
import '../interfaces/air_quality_service.dart';
import '../../../models/air_quality.dart';

class VirtualAirQualityService implements IAirQualityService {
  var random = Random();

  @override
  Future<AirQuality> getAirQuality() async {
    return _getAq();
  }

  @override
  Future<AqHistoryData> getLocalAq() async {
    int time = 0;

    var data = List.generate(10, (index) {
      var aq = _getAq();
      var aqh = AqHistory(
        time: time,
        temperature: aq.temperature,
        humidity: aq.humidity,
        pressure: aq.pressure,
        pm25: aq.pm25,
      );
      time += 60;

      return aqh;
    });

    return AqHistoryData(startTime: DateTime.now(), data: data);
  }

  @override
  Future<void> clearLocalAq() async {}

  AirQuality _getAq() {
    return AirQuality(
      temperature: 10 + 30 * random.nextDouble(),
      humidity: 100 * random.nextDouble(),
      pressure: 990 + 30 * random.nextDouble(),
      pm25: 5 + random.nextInt(95),
    );
  }
}
