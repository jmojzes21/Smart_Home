import '../../models/aq_history.dart';
import '../../models/aq_history_data.dart';
import 'interfaces/air_quality_service.dart';
import 'device_client.dart';
import '../../models/air_quality.dart';

class AirQualityService extends IAirQualityService {
  final DeviceClient client;

  AirQualityService(this.client);

  @override
  Future<AirQuality> getAirQuality() async {
    return AirQuality.fromJson(await client.httpGet('/sensor-data'));
  }

  @override
  Future<AqHistoryData> getLocalAq() async {
    var json = await client.httpGet('/aq-history');

    var bootTime = DateTime.parse(json['boot_time']);
    var aqHistory = json['aq_history'] as List<dynamic>;
    var data = aqHistory.map((e) => AqHistory.fromJson(e)).toList();

    return AqHistoryData(startTime: bootTime, data: data);
  }

  @override
  Future<void> clearLocalAq() async {}
}
