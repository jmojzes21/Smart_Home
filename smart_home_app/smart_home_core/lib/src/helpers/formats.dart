import 'package:intl/intl.dart';

class Formats {
  static final _dfDate = DateFormat('d.M.y');
  static final _dfTime = DateFormat('H:mm');
  static final _dfTimeSeconds = DateFormat('H:mm:ss');

  static final _dfDateTime = DateFormat('d.M.y. H:mm');
  static final _dfDateTimeSeconds = DateFormat('d.M.y. H:mm:ss');

  static String formatDate(DateTime? dateTime) {
    if (dateTime == null) return '';
    return _dfDate.format(dateTime);
  }

  static String formatTime(DateTime? dateTime, [bool seconds = true]) {
    if (dateTime == null) return '';
    var df = seconds ? _dfTimeSeconds : _dfTime;
    return df.format(dateTime);
  }

  static String formatDateTime(DateTime? dateTime, [bool seconds = true]) {
    if (dateTime == null) return '';
    var df = seconds ? _dfDateTimeSeconds : _dfDateTime;
    return df.format(dateTime);
  }
}
