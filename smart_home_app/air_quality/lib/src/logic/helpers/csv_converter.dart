import 'dart:convert';

import 'package:smart_home_core/exceptions.dart';

class CsvData {
  List<String> header = [];
  List<List<String>> rows = [];

  void checkHeader(List<String> expectedHeader) {
    if (header.length != expectedHeader.length) {
      throw AppException('Csv zaglavlje nema točan broj elemenata!');
    }

    for (int i = 0; i < header.length; i++) {
      if (header[i] != expectedHeader[i]) {
        throw AppException('Csv zaglavlje sadrži netočan element!');
      }
    }
  }

  void checkColumns() {
    int expectedColumns = header.length;

    for (var row in rows) {
      if (row.length != expectedColumns) {
        throw AppException('Csv redak nije valjani jer nema točan broj elemenata! ${row.join(', ')}');
      }
    }
  }
}

class CsvConverter {
  String separator = ',';

  String toCsv(CsvData data) {
    var columnSeparator = '$separator ';

    var b = StringBuffer();
    b.writeAll(data.header, columnSeparator);
    b.writeln();

    for (var row in data.rows) {
      b.writeAll(row, columnSeparator);
      b.writeln();
    }

    return b.toString();
  }

  CsvData parseCsv(String input) {
    var ls = LineSplitter();
    var lines = ls.convert(input);

    var it = lines.map((e) => e.trim()).where((e) => _includeLine(e)).iterator;

    var csvData = CsvData();

    if (it.moveNext()) throw AppException('Csv nema zaglavlje!');
    csvData.header = _parseRow(it.current);

    while (it.moveNext()) {
      csvData.rows.add(_parseRow(it.current));
    }

    return csvData;
  }

  List<String> _parseRow(String row) {
    List<String> parts = row.split(separator);
    return parts.map((e) => e.trim()).toList();
  }

  bool _includeLine(String line) {
    return line.isNotEmpty && !line.startsWith('#');
  }
}
