class PowerSensorData {
  bool isActive = false;

  double current = 0;
  double minCurrent = 0;
  double maxCurrent = 0;

  double voltage = 0;
  double minVoltage = 0;
  double maxVoltage = 0;

  PowerSensorData();

  factory PowerSensorData.fromJson(Map<String, dynamic> src) {
    var data = PowerSensorData();
    data.isActive = src['active'];

    if (data.isActive) {
      data.isActive = src['active'];
      data.current = src['current'].toDouble();
      data.minCurrent = src['minCurrent'].toDouble();
      data.maxCurrent = src['maxCurrent'].toDouble();
      data.voltage = src['voltage'].toDouble();
      data.minVoltage = src['minVoltage'].toDouble();
      data.maxVoltage = src['maxVoltage'].toDouble();
    }

    return data;
  }

  String get currentString => '${current.round()} mA';
  String get minCurrentString => 'Min: ${minCurrent.round()} mA';
  String get maxCurrentString => 'Max: ${maxCurrent.round()} mA';

  String get voltageString => '${voltage.toStringAsFixed(2)} V';
  String get minVoltageString => 'Min: ${minVoltage.toStringAsFixed(2)} V';
  String get maxVoltageString => 'Max: ${maxVoltage.toStringAsFixed(2)} V';
}
