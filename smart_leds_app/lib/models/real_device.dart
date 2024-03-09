import 'dart:convert';

import 'package:http/http.dart' as http;
import 'package:smart_leds_app/models/exceptions.dart';
import 'package:smart_leds_app/models/firmware.dart';

import 'device.dart';
import 'device_info.dart';

class RealDevice extends Device {
  int httpPort;

  RealDevice({
    required super.name,
    required super.ipAddress,
    required this.httpPort,
  });

  @override
  Future<DeviceInfo> getDeviceInfo() async {
    var res = await http.get(Uri.http(ipAddress.address, '/device'));

    var json = jsonDecode(res.body);
    var info = DeviceInfo.fromJson(json);

    return info;
  }

  @override
  Future<void> updateFirmware(Firmware firmware) async {
    Uri uri = Uri.http(ipAddress.address, 'firmware_update');
    http.Response response;
    String message;

    try {
      response = await http.post(
        uri,
        headers: {
          'Device-Type': firmware.deviceType,
          'Firmware-Size': firmware.bytes.length.toString(),
          'Firmware-HMAC': firmware.hmac,
        },
        body: firmware.bytes,
      );

      message = jsonDecode(response.body)['msg'] ?? '';
    } on Exception catch (_) {
      throw FirmwareUpdateException('Povezivanje na uređaj nije uspjelo.');
    }

    if (response.statusCode != 201) {
      throw FirmwareUpdateException(message);
    }
  }
}
