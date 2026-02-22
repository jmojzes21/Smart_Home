import '../../models/aq_history.dart';
import 'csv_converter.dart';

class AqHistoryCsvConverter {
  final List<String> _csvHeader = [
    'date_time',
    'temp_avg',
    'temp_min',
    'temp_max',
    'hum_avg',
    'hum_min',
    'hum_max',
    'press_avg',
    'press_min',
    'press_max',
    'pm25_avg',
    'pm25_min',
    'pm25_max',
  ];

  String toCsv(List<AqHistory> aqHistory) {
    var csvData = CsvData();

    csvData.header = _csvHeader;

    for (var aq in aqHistory) {
      csvData.rows.add([
        aq.time.toIso8601String(),
        ..._getMetricsValues(aq.temperature),
        ..._getMetricsValues(aq.humidity),
        ..._getMetricsValues(aq.pressure),
        ..._getMetricsValues(aq.pm25),
      ]);
    }

    var csvConverter = CsvConverter();
    return csvConverter.toCsv(csvData);
  }

  List<String> _getMetricsValues(AqMetrics metrics) {
    return [metrics.average.toString(), metrics.min.toString(), metrics.max.toString()];
  }
}
