import 'package:air_quality_app/logic/services/air_quality_service.dart';
import 'package:air_quality_app/logic/vm/view_model.dart';
import 'package:air_quality_app/models/air_quality.dart';

class HomePageViewModel extends ViewModel {
  final IAirQualityService aqService;

  AirQuality airQuality = AirQuality.empty();
  double temperatureProgress = 0;
  double humidityProgress = 0;
  double pressureProgress = 0;

  HomePageViewModel({required this.aqService});

  Future<void> getAirQuality() async {
    airQuality = await aqService.getAirQuality();
    temperatureProgress = _getProgress(airQuality.temperature, 0, 40);
    humidityProgress = _getProgress(airQuality.humidity, 0, 100);
    pressureProgress = _getProgress(airQuality.pressure, 990, 1020);
    notifyListeners();
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
