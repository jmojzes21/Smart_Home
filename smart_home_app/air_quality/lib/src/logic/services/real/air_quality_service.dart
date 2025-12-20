import 'package:smart_home_core/device.dart';

import '../air_quality_service.dart';
import '../device_client.dart';
import '../../../models/air_quality.dart';
import '../../../models/sensor_data.dart';

class AirQualityService extends IAirQualityService {
  final DeviceClient client;

  AirQualityService(Device device) : client = DeviceClient(device);

  @override
  Future<AirQuality> getAirQuality() async {
    var sensorData = SensorData.fromJson(await client.httpGet('/sensor-data'));
    return AirQuality(
      temperature: sensorData.bme280Temperature,
      humidity: sensorData.bme280Humidity,
      pressure: sensorData.bme280Pressure,
      pm25: sensorData.pm25,
    );
  }
}
