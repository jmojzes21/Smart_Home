const _jsonHostname = "hostname";
const _jsonDeviceName = "device_name";
const _jsonRecentPeriod = "recent_data_period";
const _jsonWifiNetworks = "wifi_networks";
const _jsonWifiSsid = "ssid";
const _jsonWifiPassword = "password";

const _jsonAqm = "aqm";
const _jsonAqmDeviceUuid = "device_uuid";
const _jsonAqmBackendAddress = "backend_addr";
const _jsonAqmApiKey = "api_key";
const _jsonAqmSaveMeasurements = "save_measurements";
const _jsonAqmSendData = "send_data";
const _jsonAqmMeasurementPeriod = "measurement_period";

class WifiNetwork {
  String name;
  String password;

  WifiNetwork({required this.name, required this.password});

  factory WifiNetwork.fromJson(Map<String, dynamic> json) {
    return WifiNetwork(
      name: json[_jsonWifiSsid],
      password: json[_jsonWifiPassword],
    );
  }

  Map<String, dynamic> toJson() {
    return {_jsonWifiSsid: name, _jsonWifiPassword: password};
  }

  WifiNetwork clone() {
    return WifiNetwork(name: name, password: password);
  }
}

class AqmConfig {
  /// Device UUID
  String deviceUuid;

  /// Backend address
  String backendAddress;

  /// Api key
  String apiKey;

  /// Save air quality measurements or not
  bool saveMeasurements;

  /// Send measurements and logs to the backend or not
  bool sendData;

  /// Time period in seconds for saving measurements
  int measurementPeriod;

  AqmConfig({
    required this.deviceUuid,
    required this.backendAddress,
    required this.apiKey,
    required this.saveMeasurements,
    required this.sendData,
    required this.measurementPeriod,
  });

  factory AqmConfig.fromJson(Map<String, dynamic> json) {
    return AqmConfig(
      deviceUuid: json[_jsonAqmDeviceUuid],
      backendAddress: json[_jsonAqmBackendAddress],
      apiKey: json[_jsonAqmApiKey],
      saveMeasurements: json[_jsonAqmSaveMeasurements],
      sendData: json[_jsonAqmSendData],
      measurementPeriod: json[_jsonAqmMeasurementPeriod],
    );
  }

  Map<String, dynamic> toJson() {
    return {
      _jsonAqmDeviceUuid: deviceUuid,
      _jsonAqmBackendAddress: backendAddress,
      _jsonAqmApiKey: apiKey,
      _jsonAqmSaveMeasurements: saveMeasurements,
      _jsonAqmSendData: sendData,
      _jsonAqmMeasurementPeriod: measurementPeriod,
    };
  }

  AqmConfig clone() {
    return AqmConfig(
      deviceUuid: deviceUuid,
      backendAddress: backendAddress,
      apiKey: apiKey,
      saveMeasurements: saveMeasurements,
      sendData: sendData,
      measurementPeriod: measurementPeriod,
    );
  }
}

class DeviceConfig {
  /// mDNS device hostname
  String hostname;

  /// Device name
  String deviceName;

  /// Time period in seconds for saving measurements to recent data
  int recentPeriod;

  AqmConfig aqmConfig;

  List<WifiNetwork> wifiNetworks;

  DeviceConfig({
    required this.hostname,
    required this.deviceName,
    required this.recentPeriod,
    required this.aqmConfig,
    required this.wifiNetworks,
  });

  void updateWifiNetworks(List<WifiNetwork> networks) {
    wifiNetworks = networks;
  }

  DeviceConfig clone() {
    return DeviceConfig(
      hostname: hostname,
      deviceName: deviceName,
      recentPeriod: recentPeriod,
      aqmConfig: aqmConfig.clone(),
      wifiNetworks: wifiNetworks.map((e) => e.clone()).toList(),
    );
  }

  factory DeviceConfig.fromJson(Map<String, dynamic> json) {
    return DeviceConfig(
      hostname: json[_jsonHostname],
      deviceName: json[_jsonDeviceName],
      recentPeriod: json[_jsonRecentPeriod],
      aqmConfig: AqmConfig.fromJson(json[_jsonAqm]),
      wifiNetworks: (json[_jsonWifiNetworks] as List<dynamic>)
          .map((e) => WifiNetwork.fromJson(e))
          .toList(),
    );
  }

  Map<String, dynamic> toJson() {
    return {
      _jsonHostname: hostname,
      _jsonDeviceName: deviceName,
      _jsonRecentPeriod: recentPeriod,
      _jsonAqm: aqmConfig.toJson(),
      _jsonWifiNetworks: wifiNetworks.map((e) => e.toJson()).toList(),
    };
  }
}
