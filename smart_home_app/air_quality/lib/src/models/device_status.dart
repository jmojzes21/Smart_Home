class DeviceStatus {
  String name;
  String hostname;
  String version;

  String ipAddress;
  String ssid;
  int rssi;

  /// Input voltage in volts
  double inputVoltage;

  double inputVoltagePercent = 0;

  MemoryStatus memory;

  DeviceStatus({
    this.name = '',
    this.hostname = '',
    this.version = '',
    this.ipAddress = '',
    this.ssid = '',
    this.rssi = 0,
    this.inputVoltage = 0,
    required this.memory,
  }) {
    inputVoltagePercent = calculateInputVoltagePercent(inputVoltage);
  }

  double calculateInputVoltagePercent(double inputVoltage) {
    double minVoltage = 3.6;
    double maxVoltage = 4.2;

    double voltage = inputVoltage.clamp(minVoltage, maxVoltage);

    double r = maxVoltage - minVoltage;
    double p = (voltage - minVoltage) / r;

    return p;
  }

  factory DeviceStatus.fromJson(Map<String, dynamic> json) {
    var ram = json['ram'];

    int heapSize = ram['heap_size'];
    int freeHeap = ram['free_heap'];
    int minFreeHeap = ram['min_free_heap'];
    int usedHeap = heapSize - freeHeap;
    int maxUsedHeap = heapSize - minFreeHeap;

    int psramSize = ram['psram_size'];
    int freePsram = ram['free_psram'];
    int minFreePsram = ram['min_free_psram'];
    int usedPsram = psramSize - freePsram;
    int maxUsedPsram = psramSize - minFreePsram;

    int inputVoltage = json['input_voltage'];

    return DeviceStatus(
      name: json['name'],
      hostname: json['hostname'],
      version: json['version'],
      ipAddress: json['ip'],
      ssid: json['ssid'],
      rssi: json['rssi'],
      inputVoltage: inputVoltage / 1000.0,
      memory: MemoryStatus(
        heapSize: _toKB(heapSize),
        usedHeap: _toKB(usedHeap),
        maxUsedHeap: _toKB(maxUsedHeap),
        psramSize: _toKB(psramSize),
        usedPsram: _toKB(usedPsram),
        maxUsedPsram: _toKB(maxUsedPsram),
      ),
    );
  }

  static _toKB(int inBytes) {
    return inBytes / 1024.0;
  }
}

class MemoryStatus {
  /// Heap size in KB
  double heapSize;

  /// Used heap in KB
  double usedHeap;

  /// Max used heap in KB
  double maxUsedHeap;

  /// PSRAM size in KB
  double psramSize;

  /// Used PSRAM in KB
  double usedPsram;

  /// Max PSRAM heap in KB
  double maxUsedPsram;

  double usedHeapPercent = 0;
  double maxUsedHeapPercent = 0;

  double usedPsramPercent = 0;
  double maxUsedPsramPercent = 0;

  MemoryStatus({
    this.heapSize = 0,
    this.usedHeap = 0,
    this.maxUsedHeap = 0,
    this.psramSize = 0,
    this.usedPsram = 0,
    this.maxUsedPsram = 0,
  }) {
    if (heapSize != 0) {
      usedHeapPercent = usedHeap / heapSize;
      maxUsedHeapPercent = maxUsedHeap / heapSize;
    }

    if (psramSize != 0) {
      usedPsramPercent = usedPsram / psramSize;
      maxUsedPsramPercent = maxUsedPsram / psramSize;
    }
  }
}
