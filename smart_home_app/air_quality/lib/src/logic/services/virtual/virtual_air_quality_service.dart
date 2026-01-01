import 'dart:math';

import '../interfaces/air_quality_service.dart';
import '../../../models/air_quality.dart';

class VirtualAirQualityService implements IAirQualityService {
  var random = Random();

  @override
  Future<AirQuality> getAirQuality() {
    return Future.value(
      AirQuality(
        temperature: 10 + 30 * random.nextDouble(),
        humidity: 100 * random.nextDouble(),
        pressure: 990 + 30 * random.nextDouble(),
        pm25: 5 + random.nextInt(95),
      ),
    );
  }
}
