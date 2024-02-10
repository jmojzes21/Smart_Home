import 'dart:async';
import 'dart:developer';
import 'dart:io';

import 'package:multicast_dns/multicast_dns.dart';
import 'package:smart_leds_app/models/discovered_device.dart';

class DeviceDiscovery {
  bool _isDiscovering = false;
  MDnsClient? _client;

  Stream<DiscoveredDevice> start() {
    if (_isDiscovering) throw Exception('Otkrivanje uređaja u tijeku!');

    _isDiscovering = true;

    var streamController = StreamController<DiscoveredDevice>();
    _start(streamController);

    return streamController.stream;
  }

  void _start(StreamController<DiscoveredDevice> streamController) async {
    const String serviceName = '_http._tcp.local';
    const String targetName = 'smart_leds.local';

    // izvor: https://github.com/flutter/packages/blob/main/packages/multicast_dns/example/mdns_sd.dart
    log('Započni pretraživanje uređaja');

    _client = MDnsClient(rawDatagramSocketFactory: _rawDatagramSocketFactory);
    await _client!.start();

    await for (final PtrResourceRecord ptr in _client!
        .lookup<PtrResourceRecord>(
            ResourceRecordQuery.serverPointer(serviceName))) {
      await for (final SrvResourceRecord srv in _client!
          .lookup<SrvResourceRecord>(
              ResourceRecordQuery.service(ptr.domainName))) {
        await for (final IPAddressResourceRecord ip in _client!
            .lookup<IPAddressResourceRecord>(
                ResourceRecordQuery.addressIPv4(srv.target))) {
          if (srv.target == targetName) {
            var deviceName =
                srv.name.substring(0, srv.name.length - serviceName.length - 1);

            log('Pronađen uređaj $deviceName, IP: ${ip.address.address}');

            streamController.sink.add(DiscoveredDevice(
              name: deviceName,
              ipAddress: ip.address,
              httpPort: srv.port,
            ));
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

  Future<RawDatagramSocket> _rawDatagramSocketFactory(
    dynamic host,
    int port, {
    bool? reuseAddress,
    bool? reusePort,
    int? ttl,
  }) {
    return RawDatagramSocket.bind(host, port,
        reuseAddress: true, reusePort: false, ttl: ttl!);
  }
}


/*

// Copyright 2013 The Flutter Authors. All rights reserved.
// Use of this source code is governed by a BSD-style license that can be
// found in the LICENSE file.

// Example script to illustrate how to use the mdns package to discover services
// on the local network.

// ignore_for_file: avoid_print

import 'dart:async';
import 'dart:io';

import 'package:multicast_dns/multicast_dns.dart';

class DeviceInfo {
  final String hostname;
  final InternetAddress internetAddress;
  final int port;

  DeviceInfo({
    required this.hostname,
    required this.internetAddress,
    required this.port,
  });

  String get address => '${internetAddress.address}:$port';

  @override
  String toString() {
    return '$hostname:$port (${internetAddress.address})';
  }
}

Future<DeviceInfo?> scan() async {
  final completer = Completer<DeviceInfo?>();
  _scan(completer);

  return completer.future;
}

void _scan(Completer<DeviceInfo?> completer) async {
  const String name = '_http._tcp.local';
  print('Scan started');

  final MDnsClient client = MDnsClient(rawDatagramSocketFactory:
      (dynamic host, int port,
          {bool? reuseAddress, bool? reusePort, int? ttl}) {
    return RawDatagramSocket.bind(host, port,
        reuseAddress: true, reusePort: false, ttl: ttl!);
  });
  await client.start();

  await for (final PtrResourceRecord ptr in client
      .lookup<PtrResourceRecord>(ResourceRecordQuery.serverPointer(name))) {
    await for (final SrvResourceRecord srv in client.lookup<SrvResourceRecord>(
        ResourceRecordQuery.service(ptr.domainName))) {
      await for (final IPAddressResourceRecord ip
          in client.lookup<IPAddressResourceRecord>(
              ResourceRecordQuery.addressIPv4(srv.target))) {
        var device = DeviceInfo(
          hostname: srv.target,
          internetAddress: ip.address,
          port: srv.port,
        );
        print('Found $device');
        if (completer.isCompleted == false) {
          completer.complete(device);
        }
      }
    }
  }

  client.stop();
  print('Scan finished');

  if (completer.isCompleted == false) {
    completer.complete(null);
  }
}


*/
