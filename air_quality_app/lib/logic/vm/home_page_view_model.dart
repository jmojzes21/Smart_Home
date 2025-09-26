import 'dart:async';

import 'package:air_quality_app/logic/exceptions.dart';
import 'package:air_quality_app/logic/services/air_quality_service.dart';
import 'package:air_quality_app/logic/vm/view_model.dart';
import 'package:air_quality_app/models/air_quality.dart';

class HomePageViewModel extends ViewModel {
  final IAirQualityService aqService;
  final Function(String message) openExceptionPage;

  AirQuality airQuality = AirQuality.empty();
  double temperatureProgress = 0;
  double humidityProgress = 0;
  double pressureProgress = 0;
  double pm25Progress = 0;

  bool isLoading = true;

  Timer? _refreshTimer;

  HomePageViewModel({required this.aqService, required this.openExceptionPage}) {
    _init();
  }

  Future<void> _init() async {
    try {
      await getAirQuality();
    } on AppException catch (e) {
      openExceptionPage(e.message);
      return;
    }

    isLoading = false;
    notifyListeners();

    _refreshTimer = Timer.periodic(Duration(seconds: 2), (timer) => _onRefresh());
  }

  Future<void> getAirQuality() async {
    airQuality = await aqService.getAirQuality();

    temperatureProgress = _getProgress(airQuality.temperature, 0, 40);
    humidityProgress = _getProgress(airQuality.humidity, 0, 100);
    pressureProgress = _getProgress(airQuality.pressure, 990, 1020);
    pm25Progress = _getProgress(airQuality.pm25.toDouble(), 0, 100);

    notifyListeners();
  }

  Future<void> _onRefresh() async {
    try {
      await getAirQuality();
    } on AppException catch (e) {
      _refreshTimer?.cancel();
      openExceptionPage(e.message);
    }
  }

  @override
  void dispose() {
    _refreshTimer?.cancel();
    super.dispose();
  }

  double _getProgress(double value, double minValue, double maxValue) {
    if (value > maxValue) {
      value = maxValue;
    } else if (value < minValue) {
      value = minValue;
    }
    double r = maxValue - minValue;
    return (value - minValue) / r;
  }
}
