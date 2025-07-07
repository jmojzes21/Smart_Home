import 'dart:convert';

import 'package:http/http.dart' as http;
import 'package:shtc3_sensor_app/logic/exceptions.dart';
import 'package:shtc3_sensor_app/models/sensor_data.dart';

class DeviceController {
  static const String _deviceHostname = 'shtc3_sensor.local';

  Future<SensorData> getSensorData() async {
    try {
      var url = Uri.http(_deviceHostname, '/');
      var response = await http.get(url);

      var json = jsonDecode(response.body);
      return SensorData.fromJson(json);
    } on Exception catch (_) {
      throw AppException('Povezivanje s uređajem nije uspjelo!');
    }
  }
}
