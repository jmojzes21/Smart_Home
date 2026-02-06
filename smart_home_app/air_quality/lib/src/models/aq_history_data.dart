import 'dart:math';

import 'aq_history.dart';

class AqHistoryData {
  DateTime startTime;
  List<AqHistory> data = [];

  List<double> temperatureRange = [0, 0];
  List<double> humidityRange = [0, 0];
  List<double> pressureRange = [0, 0];
  List<double> pm25Range = [0, 0];

  AqHistoryData({required this.startTime, required this.data});

  void calculateRanges() {
    var temp = getMinMaxValues(data.map((e) => e.temperature).toList());
    var hum = getMinMaxValues(data.map((e) => e.humidity).toList());
    var press = getMinMaxValues(data.map((e) => e.pressure).toList());
    var pm25 = getMinMaxValues(data.map((e) => e.pm25.toDouble()).toList());

    temperatureRange = [min(10, temp[0]), max(30, temp[1])];
    humidityRange = [min(20, hum[0]), max(80, hum[1])];
    pressureRange = [min(980, press[0]), max(1020, press[1])];
    pm25Range = [min(0, pm25[0]), max(100, pm25[1])];
  }

  List<double> getMinMaxValues(List<double> values) {
    double min = values.first;
    double max = values.first;

    for (int i = 1; i < values.length; i++) {
      if (values[i] < min) {
        min = values[i];
      } else if (values[i] > max) {
        max = values[i];
      }
    }

    return [min, max];
  }

  DateTime getDateTime(int seconds) {
    return startTime.add(Duration(seconds: seconds));
  }
}
