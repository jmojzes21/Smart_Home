import 'dart:async';
import 'dart:developer';

import 'package:multicast_dns/multicast_dns.dart';
import 'device/device.dart';

class DeviceDiscovery {
  bool _isDiscovering = false;
  MDnsClient? _client;

  Stream<Device> start() {
    if (_isDiscovering) throw Exception('Otkrivanje uređaja u tijeku!');

    _isDiscovering = true;

    var streamController = StreamController<Device>();
    _start(streamController);

    return streamController.stream;
  }

  void _start(StreamController<Device> streamController) async {
    const String serviceName = '_http._tcp.local';
    const String targetName = 'smart_leds.local';

    // izvor: https://github.com/flutter/packages/blob/main/packages/multicast_dns/example/mdns_sd.dart
    log('Započni pretraživanje uređaja');

    _client = MDnsClient();

    try {
      await _client!.start();
    } on Exception catch (_) {
      _isDiscovering = false;
      streamController.close();
      return;
    }

    await for (final PtrResourceRecord ptr in _client!.lookup<PtrResourceRecord>(ResourceRecordQuery.serverPointer(serviceName))) {
      await for (final SrvResourceRecord srv in _client!.lookup<SrvResourceRecord>(ResourceRecordQuery.service(ptr.domainName))) {
        await for (final IPAddressResourceRecord ip in _client!.lookup<IPAddressResourceRecord>(ResourceRecordQuery.addressIPv4(srv.target))) {
          if (srv.target == targetName) {
            var deviceName = srv.name.substring(0, srv.name.length - serviceName.length - 1);

            log('Pronađen uređaj $deviceName, IP: ${ip.address.address}');

            streamController.sink.add(Device(name: deviceName, ipAddress: ip.address));
          }
        }
      }
    }

    _client!.stop();
    _client = null;

    _isDiscovering = false;
    streamController.close();

    log('Pretraživanje uređaja gotovo');
  }

  void stop() {
    if (_isDiscovering) {
      _client?.stop();
    }
  }
}
