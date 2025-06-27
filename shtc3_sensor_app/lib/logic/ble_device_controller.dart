import 'dart:async';
import 'dart:typed_data';

import 'package:flutter_blue_plus/flutter_blue_plus.dart';
import 'package:shtc3_sensor_app/logic/device_controller.dart';
import 'package:shtc3_sensor_app/logic/exceptions.dart';
import 'package:shtc3_sensor_app/models/sensor_data.dart';

class BleDeviceController extends DeviceController {
  static const _sensorServiceUuid = "2020";
  static const _sensorDataCharUuid = "2021";

  final BluetoothDevice _device;
  BluetoothService? _sensorService;
  BluetoothCharacteristic? _sensorDataChar;
  StreamSubscription<List<int>>? _sensorDataCharSubscription;

  final _streamController = StreamController<SensorData>();

  BleDeviceController(this._device) : super(_device.platformName);

  @override
  Future<void> connect() async {
    List<BluetoothService> services;

    try {
      await _device.connect(timeout: Duration(seconds: 4));
      services = await _device.discoverServices(timeout: 4);
    } on FlutterBluePlusException catch (_) {
      throw AppException('Povezivanje uređaja nije moguće.');
    }

    _sensorService = _findService(services, _sensorServiceUuid);
    _sensorDataChar = _findCharacteristic(_sensorService!, _sensorDataCharUuid);

    await _sensorDataChar!.setNotifyValue(true);
    _sensorDataCharSubscription = _sensorDataChar!.onValueReceived.listen((data) {
      if (data.length != 8) {
        return;
      }

      var byteData = ByteData.view(Uint8List.fromList(data).buffer);
      var sensorData = SensorData(
        temperature: byteData.getFloat32(0, Endian.little),
        humidity: byteData.getFloat32(4, Endian.little),
      );
      _streamController.sink.add(sensorData);
    });
  }

  @override
  Future<void> disconnect() async {
    _streamController.close();

    _sensorDataCharSubscription?.cancel();
    _sensorDataCharSubscription = null;
    _sensorService = null;
    _sensorDataChar = null;

    try {
      await _device.disconnect(timeout: 4);
    } on FlutterBluePlusException catch (_) {}
  }

  BluetoothService _findService(List<BluetoothService> services, String uuid) {
    var index = services.indexWhere((e) => e.uuid.str == uuid);
    if (index == -1) {
      throw AppException('Uređaj nije podržan.');
    }
    return services[index];
  }

  BluetoothCharacteristic _findCharacteristic(BluetoothService service, String uuid) {
    var index = service.characteristics.indexWhere((e) => e.uuid.str == uuid);
    if (index == -1) {
      throw AppException('Uređaj nije podržan.');
    }
    return service.characteristics[index];
  }

  @override
  Stream<SensorData> get sensorDataStream => _streamController.stream;
}
