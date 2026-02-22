import 'dart:async';
import 'dart:math';

import '../../../models/aq_history.dart';
import '../interfaces/air_quality_service.dart';
import '../../../models/air_quality.dart';

class VirtualAirQualityService implements IAirQualityService {
  final Random _random = Random();

  final StreamController<AirQuality> _liveDataController = StreamController.broadcast();
  Timer? _liveDataTimer;

  @override
  Future<AirQuality> getAirQuality() async {
    return _getAq();
  }

  @override
  Future<void> startLiveData() async {
    if (_liveDataTimer != null) return;

    _liveDataTimer = Timer.periodic(Duration(seconds: 2), (timer) {
      _liveDataController.sink.add(_getAq());
    });
  }

  @override
  void stopLiveData() {
    _liveDataTimer?.cancel();
    _liveDataTimer = null;
  }

  @override
  Stream<AirQuality> getLiveDataStream() {
    return _liveDataController.stream;
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
      temperature: 10 + 30 * _random.nextDouble(),
      humidity: 100 * _random.nextDouble(),
      pressure: 990 + 30 * _random.nextDouble(),
      pm25: 5 + _random.nextInt(95),
    );
  }

  AqMetrics _getAqMetrics(double value, double d) {
    double p1 = _random.nextDouble();
    double p2 = _random.nextDouble();
    return AqMetrics(average: value, min: value - p1 * d, max: value + p2 * d);
  }
}
