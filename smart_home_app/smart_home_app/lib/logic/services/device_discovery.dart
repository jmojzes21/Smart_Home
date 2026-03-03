import 'dart:async';
import 'dart:convert';
import 'dart:developer';
import 'dart:io';

import 'package:http/http.dart' as http;
import 'package:multicast_dns/multicast_dns.dart';
import 'package:smart_home_core/device.dart';
import 'package:smart_home_core/exceptions.dart';

import '../../models/generic_device.dart';

class DeviceDiscovery {
  static const String _serviceName = '_smart-home._tcp.local';
  static const Duration _connectTimeout = Duration(seconds: 4);

  bool _isDiscovering = false;
  StreamController<Device>? _streamController;
  MDnsClient? _client;

  Stream<Device> start() {
    if (_isDiscovering) throw StateError('Otkrivanje uređaja u tijeku!');

    _isDiscovering = true;

    _streamController = StreamController<Device>();
    _start();

    return _streamController!.stream;
  }

  void _start() async {
    log('Započni pretraživanje uređaja');

    _client = MDnsClient(rawDatagramSocketFactory: _rawDatagramSocketFactory);

    try {
      await _client!.start();
    } on Exception catch (e) {
      log(e.toString());

      _streamController?.close();
      _client = null;
      _streamController = null;
      _isDiscovering = false;
      return;
    }

    await for (final PtrResourceRecord ptr in _client!.lookup<PtrResourceRecord>(
      ResourceRecordQuery.serverPointer(_serviceName),
    )) {
      await for (final SrvResourceRecord srv in _client!.lookup<SrvResourceRecord>(
        ResourceRecordQuery.service(ptr.domainName),
      )) {
        await for (final IPAddressResourceRecord ip in _client!.lookup<IPAddressResourceRecord>(
          ResourceRecordQuery.addressIPv4(srv.target),
        )) {
          log('Pronađen uređaj ${srv.name}, IP: ${ip.address.address}');
          _getDeviceInfo(ip.address);
        }
      }
    }

    _streamController?.close();
    _client!.stop();

    _streamController = null;
    _client = null;

    _isDiscovering = false;
    log('Pretraživanje uređaja gotovo');
  }

  void stop() {
    if (_isDiscovering) {
      _client?.stop();
    }
  }

  Future<void> _getDeviceInfo(InternetAddress ipAddress) async {
    try {
      var url = Uri.http(ipAddress.address, '/device');
      var response = await http.get(url).timeout(_connectTimeout);

      if (response.statusCode != 200) {
        return;
      }

      var json = jsonDecode(response.body);
      var device = _parseGenericDevice(json);

      if (_isDiscovering) {
        _streamController?.sink.add(device);
      }
    } catch (e) {
      log(Exceptions.getMessage(e));
    }
  }

  ScannedDevice _parseGenericDevice(Map<String, dynamic> json) {
    var type = DeviceType.parse(json['type']);
    if (type == DeviceType.unknown) throw Exception('Unsupported device type ${json['type']}');

    return ScannedDevice(
      type: type,
      hostname: json['hostname'],
      uuid: json['uuid'],
      name: json['name'],
      ipAddress: InternetAddress(json['ip']),
    );
  }

  Future<RawDatagramSocket> _rawDatagramSocketFactory(
    dynamic host,
    int port, {
    bool reuseAddress = true,
    bool reusePort = false,
    int ttl = 1,
  }) {
    return RawDatagramSocket.bind(host, port, reuseAddress: true, reusePort: false, ttl: ttl);
  }
}
