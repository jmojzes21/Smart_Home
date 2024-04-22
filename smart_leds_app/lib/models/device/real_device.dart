import 'dart:convert';

import 'package:http/http.dart' as http;
import 'package:smart_leds_app/models/exceptions.dart';
import 'package:smart_leds_app/models/firmware.dart';

import 'device.dart';

class RealDevice extends Device {
  RealDevice({required super.ipAddress});

  @override
  Future<void> getDeviceInfo() async {
    var res = await http.get(Uri.http(ipAddress.address, '/device'));

    var json = jsonDecode(res.body);

    String name = json['name'];
    String type = json['type'];
    String firmwareVersion = json['version'];
    String macAddress = json['mac'];

    this.name = name;
    this.type = type;
    this.firmwareVersion = firmwareVersion;
    this.macAddress = macAddress;
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
