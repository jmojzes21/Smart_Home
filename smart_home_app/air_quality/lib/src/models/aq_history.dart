class AqMetrics {
  double average;
  double min;
  double max;

  AqMetrics({required this.average, required this.min, required this.max});

  AqMetrics.live(double value) : average = value, min = value, max = value;

  factory AqMetrics.fromJson(Map<String, dynamic> json) {
    return AqMetrics(average: json['average'].toDouble(), min: json['min'].toDouble(), max: json['max'].toDouble());
  }
}

class AqHistory {
  DateTime time;

  AqMetrics temperature;
  AqMetrics humidity;
  AqMetrics pressure;
  AqMetrics pm25;

  AqHistory({
    required this.time,
    required this.temperature,
    required this.humidity,
    required this.pressure,
    required this.pm25,
  });
}
