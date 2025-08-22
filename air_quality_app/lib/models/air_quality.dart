class AirQuality {
  final double temperature;
  final double humidity;
  final double pressure;

  AirQuality.empty() : temperature = 0, humidity = 0, pressure = 0;
  AirQuality({required this.temperature, required this.humidity, required this.pressure});
}
