import 'dart:async';
import 'dart:convert';
import 'dart:developer';

import 'package:smart_home_core/exceptions.dart';
import 'package:smart_home_core/services.dart';
import 'package:web_socket_channel/web_socket_channel.dart';

import '../../models/aq_history.dart';
import 'interfaces/air_quality_service.dart';
import 'device_client.dart';
import '../../models/air_quality.dart';

class AirQualityService extends IAirQualityService {
  final DeviceClient client;

  final StreamController<AirQuality> _liveDataController = StreamController.broadcast();

  bool _isLiveDataListening = false;
  WebSocketChannel? _wsChannel;
  StreamSubscription? _wsStreamSub;

  AirQualityService(this.client);

  @override
  Future<AirQuality> getAirQuality() async {
    return AirQuality.fromJson(await client.httpGet('/sensor-data'));
  }

  @override
  Future<void> startLiveData() async {
    if (_isLiveDataListening) return;

    var hostname = client.device.ipAddress!.address;
    var url = Uri.parse('ws://$hostname/sensor-data-ws');

    _wsChannel = WebSocketChannel.connect(url);
    await _wsChannel!.ready;

    _wsStreamSub = _wsChannel!.stream.listen((data) {
      if (data is String) {
        _onWebSocketSensorData(data);
      }
    });

    _isLiveDataListening = true;
  }

  void _onWebSocketSensorData(String data) {
    try {
      Map<String, dynamic> json = jsonDecode(data);
      AirQuality aq = AirQuality.fromJson(json);

      _liveDataController.sink.add(aq);
    } catch (e) {
      String msg = Exceptions.getMessage(e);
      log(msg);
    }
  }

  @override
  void stopLiveData() {
    _wsStreamSub?.cancel();
    _wsChannel?.sink.close();

    _wsStreamSub = null;
    _wsChannel = null;
    _isLiveDataListening = false;
  }

  @override
  Stream<AirQuality> getLiveDataStream() {
    return _liveDataController.stream;
  }

  @override
  Future<List<AqHistory>> getRecentHistory() async {
    var json = await client.httpGet('/aq-history');

    var bootTime = DateTime.parse(json['boot_time']);
    var aqHistory = json['aq_history'] as List<dynamic>;

    var data = aqHistory.map((e) => _parseRecentAqHistory(bootTime, e)).toList();
    return data;
  }

  @override
  Future<void> clearRecentHistory() async {
    await client.httpDelete('/aq-history', statusCode: 200);
  }

  @override
  Future<List<AqHistory>> getHistory(DateTime start, DateTime end) async {
    String uuid = client.device.uuid;

    var backendClient = BackendClient();
    var data = await backendClient.httpGet('/api/air_quality/device/$uuid', {
      'from': start.toIso8601String(),
      'to': end.toIso8601String(),
    });

    var aqHistory = data as List<dynamic>;
    var aqData = aqHistory.map((e) => _parseAqHistory(e)).toList();
    aqData.sort((a, b) => a.time.compareTo(b.time));

    return aqData;
  }

  AqHistory _parseRecentAqHistory(DateTime bootTime, Map<String, dynamic> json) {
    int timeSeconds = json['time'];
    DateTime time = bootTime.add(Duration(seconds: timeSeconds));

    return AqHistory(
      time: time,
      temperature: AqMetrics.fromJson(json['temperature']),
      humidity: AqMetrics.fromJson(json['humidity']),
      pressure: AqMetrics.fromJson(json['pressure']),
      pm25: AqMetrics.fromJson(json['pm25']),
    );
  }

  AqHistory _parseAqHistory(Map<String, dynamic> json) {
    return AqHistory(
      time: DateTime.parse(json['time']),
      temperature: AqMetrics.fromJson(json['temperature']),
      humidity: AqMetrics.fromJson(json['humidity']),
      pressure: AqMetrics.fromJson(json['pressure']),
      pm25: AqMetrics.fromJson(json['pm25']),
    );
  }
}
