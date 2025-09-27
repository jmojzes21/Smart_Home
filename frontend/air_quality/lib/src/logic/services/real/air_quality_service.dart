import '../air_quality_service.dart';
import '../device_client.dart';
import '../../../models/air_quality.dart';
import '../../../models/sensor_data.dart';

class AirQualityService extends IAirQualityService {
  final device = DeviceClient();

  @override
  Future<AirQuality> getAirQuality() async {
    var sensorData = SensorData.fromJson(await device.httpGet('/'));
    return AirQuality(temperature: sensorData.bme280Temperature, humidity: sensorData.bme280Humidity, pressure: sensorData.bme280Pressure, pm25: sensorData.pm25);
  }
}
