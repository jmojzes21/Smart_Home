class PowerSensorData {
  bool isActive = false;

  double current = 0;
  double minCurrent = 0;
  double maxCurrent = 0;

  double voltage = 0;
  double minVoltage = 0;
  double maxVoltage = 0;

  PowerSensorData();

  String get currentString => '${current.round()} mA';
  String get minCurrentString => 'Min: ${minCurrent.round()} mA';
  String get maxCurrentString => 'Max: ${maxCurrent.round()} mA';

  String get voltageString => '${voltage.toStringAsFixed(2)} V';
  String get minVoltageString => 'Min: ${minVoltage.toStringAsFixed(2)} V';
  String get maxVoltageString => 'Max: ${minVoltage.toStringAsFixed(2)} V';
}
