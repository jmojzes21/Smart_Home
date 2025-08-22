import 'package:air_quality_app/logic/services/air_quality_service.dart';
import 'package:air_quality_app/logic/services/device_client.dart';
import 'package:air_quality_app/models/air_quality.dart';
import 'package:air_quality_app/models/sensor_data.dart';

class AirQualityService extends IAirQualityService {
  final device = DeviceClient();

  @override
  Future<AirQuality> getAirQuality() async {
    var sensorData = SensorData.fromJson(await device.httpGet('/'));
    return AirQuality(
      temperature: sensorData.bme280Temperature,
      humidity: sensorData.bme280Humidity,
      pressure: sensorData.bme280Pressure,
    );
  }
}
