class AirQuality {
  final double temperature;
  final double humidity;
  final double pressure;
  final int pm25;

  AirQuality.empty() : temperature = 0, humidity = 0, pressure = 0, pm25 = 0;
  AirQuality({required this.temperature, required this.humidity, required this.pressure, required this.pm25});
}
