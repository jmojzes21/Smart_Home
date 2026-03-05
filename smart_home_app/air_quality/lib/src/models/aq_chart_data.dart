import 'dart:math' as math;

import 'aq_history.dart';

class AqHistoryChartData extends AqHistory {
  double x = 0;

  AqHistoryChartData(AqHistory aq)
    : super(time: aq.time, temperature: aq.temperature, humidity: aq.humidity, pressure: aq.pressure, pm25: aq.pm25);
}

class AqChartData {
  List<AqHistoryChartData> data = [];

  List<double> xRange = [0, 0];
  List<double> temperatureRange = [0, 0];
  List<double> humidityRange = [0, 0];
  List<double> pressureRange = [0, 0];
  List<double> pm25Range = [0, 0];

  bool tooltipShowDate = true;

  double _startTime = 0;

  AqChartData(List<AqHistory> data, {this.tooltipShowDate = true}) {
    if (data is List<AqHistoryChartData>) {
      this.data = data;
    } else {
      this.data = data.map((e) => AqHistoryChartData(e)).toList();
    }

    calculateValues();
  }

  void calculateValues() {
    if (data.isEmpty) return;

    _startTime = data.first.time.millisecondsSinceEpoch / 1000;
    for (var aq in data) {
      double t = aq.time.millisecondsSinceEpoch / 1000;
      aq.x = t - _startTime;
    }

    xRange[0] = data.first.x;
    xRange[1] = data.last.x;

    temperatureRange = _getRangeValues(data.map((e) => e.temperature).toList(), 10, 30);
    humidityRange = _getRangeValues(data.map((e) => e.humidity).toList(), 20, 80);
    pressureRange = _getRangeValues(data.map((e) => e.pressure).toList(), 980, 1020);
    pm25Range = _getRangeValues(data.map((e) => e.pm25).toList(), 0, 100);
  }

  DateTime getDateTimeFromX(double x) {
    double t = (_startTime + x) * 1000;
    return DateTime.fromMillisecondsSinceEpoch(t.toInt());
  }

  List<double> _getRangeValues(List<AqMetrics> values, double defaultMin, double defaultMax) {
    double min = values.first.min;
    double max = values.first.max;

    for (int i = 1; i < values.length; i++) {
      if (values[i].min < min) {
        min = values[i].min;
      }
      if (values[i].max > max) {
        max = values[i].max;
      }
    }

    min = math.min(defaultMin, min);
    max = math.max(defaultMax, max);
    return [min, max];
  }
}
