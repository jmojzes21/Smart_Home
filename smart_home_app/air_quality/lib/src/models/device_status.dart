class DeviceStatus {
  String name;
  String hostname;
  String version;

  String ipAddress;
  String ssid;
  int rssi;

  /// Heap size in bytes
  int heapSize;

  /// Free heap in bytes
  int freeHeap;

  /// Min free heap in bytes
  int minFreeHeap;

  /// Input voltage in mV
  int inputVoltage;

  DeviceStatus({
    required this.name,
    required this.hostname,
    this.version = '',
    this.ipAddress = '',
    this.ssid = '',
    this.rssi = 0,
    this.heapSize = 0,
    this.freeHeap = 0,
    this.minFreeHeap = 0,
    this.inputVoltage = 0,
  });

  double getVoltageInVolts() {
    return inputVoltage / 1000.0;
  }

  double getHeapSizeKB() {
    return heapSize / 1024.0;
  }

  double getFreeHeapKB() {
    return freeHeap / 1024.0;
  }

  double getUsedHeapKB() {
    int usedHeap = heapSize - freeHeap;
    return usedHeap / 1024.0;
  }

  double getMaxUsedHeapKB() {
    int maxUsedHeap = heapSize - minFreeHeap;
    return maxUsedHeap / 1024.0;
  }

  factory DeviceStatus.fromJson(Map<String, dynamic> json) {
    var ram = json['ram'];
    return DeviceStatus(
      name: json['name'],
      hostname: json['hostname'],
      version: json['version'],
      ipAddress: json['ip'],
      ssid: json['ssid'],
      rssi: json['rssi'],
      heapSize: ram['heap_size'],
      freeHeap: ram['free_heap'],
      minFreeHeap: ram['min_free_heap'],
      inputVoltage: json['input_voltage'],
    );
  }
}
