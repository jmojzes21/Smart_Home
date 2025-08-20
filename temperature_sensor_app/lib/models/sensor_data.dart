class SensorData {
  final double bme280Temperature;
  final double bme280Humidity;
  final double bme280Pressure;

  final double shtc3Temperature;
  final double shtc3Humidity;

  SensorData({
    required this.bme280Temperature,
    required this.bme280Humidity,
    required this.bme280Pressure,
    required this.shtc3Temperature,
    required this.shtc3Humidity,
  });

  factory SensorData.fromJson(Map<String, dynamic> json) {
    var bme280Data = json['bme280'];
    var shtc3Data = json['shtc3'];
    return SensorData(
      bme280Temperature: bme280Data['temperature'].toDouble(),
      bme280Humidity: bme280Data['humidity'].toDouble(),
      bme280Pressure: bme280Data['pressure'].toDouble(),
      shtc3Temperature: shtc3Data['temperature'].toDouble(),
      shtc3Humidity: shtc3Data['humidity'].toDouble(),
    );
  }
}
