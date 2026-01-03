import 'package:intl/intl.dart';

class Formats {
  static final _dfDateTime = DateFormat('d.M.y. H:mm');
  static final _dfDateTimeSeconds = DateFormat('d.M.y. H:mm:ss');

  static String formatDateTime(DateTime? dateTime, [bool seconds = true]) {
    if (dateTime == null) return '';
    var df = seconds ? _dfDateTimeSeconds : _dfDateTime;
    return df.format(dateTime);
  }
}
