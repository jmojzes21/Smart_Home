class AqHistory {
  /// Seconds after start time
  int time;

  double temperature;
  double humidity;
  double pressure;
  int pm25;

  AqHistory({
    required this.time,
    required this.temperature,
    required this.humidity,
    required this.pressure,
    required this.pm25,
  });

  factory AqHistory.fromJson(Map<String, dynamic> json) {
    return AqHistory(
      time: json['time'].toInt(),
      temperature: json['temperature'].toDouble(),
      humidity: json['humidity'].toDouble(),
      pressure: json['pressure'].toDouble(),
      pm25: json['pm25'].toInt(),
    );
  }
}
