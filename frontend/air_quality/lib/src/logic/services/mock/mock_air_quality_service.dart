import 'dart:math';

import 'package:air_quality/src/logic/services/air_quality_service.dart';
import 'package:air_quality/src/models/air_quality.dart';

class MockAirQualityService implements IAirQualityService {
  var random = Random();

  @override
  Future<AirQuality> getAirQuality() {
    return Future.value(AirQuality(temperature: 10 + 30 * random.nextDouble(), humidity: 100 * random.nextDouble(), pressure: 990 + 30 * random.nextDouble(), pm25: 5 + random.nextInt(95)));
  }
}
