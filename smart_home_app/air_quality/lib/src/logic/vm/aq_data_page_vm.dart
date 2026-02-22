import 'dart:io';

import 'package:smart_home_core/exceptions.dart';
import 'package:smart_home_core/view_model.dart';

import '../../models/aq_chart_data.dart';
import '../helpers/aq_history_csv_converter.dart';
import '../services/interfaces/air_quality_service.dart';

class AirQualityDataPageViewModel extends ViewModel {
  final IAirQualityService aqService;
  final Function(String message) onShowMessage;

  bool _isLoading = true;
  AqChartData? _aqData;

  AirQualityDataPageViewModel({required this.aqService, required this.onShowMessage});

  Future<void> showRecentData() async {
    _isLoading = true;
    notifyListeners();

    try {
      var data = await aqService.getRecentHistory();
      _aqData = AqChartData(data, tooltipShowDate: false);
    } catch (e) {
      String msg = Exceptions.getMessage(e);
      onShowMessage(msg);
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }

  Future<void> saveData(String path) async {
    _isLoading = true;
    notifyListeners();

    try {
      var aqConverter = AqHistoryCsvConverter();
      String csv = aqConverter.toCsv(_aqData!.data);

      var file = File(path);
      await file.writeAsString(csv);
      onShowMessage('Podaci su uspješno spremljeni. Lokacija: $path');
    } catch (e) {
      String msg = Exceptions.getMessage(e);
      onShowMessage(msg);
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }

  Future<void> clearRecentHistory() async {
    _isLoading = true;
    notifyListeners();

    try {
      await aqService.clearRecentHistory();
      var data = await aqService.getRecentHistory();
      _aqData = AqChartData(data, tooltipShowDate: false);
    } catch (e) {
      String msg = Exceptions.getMessage(e);
      onShowMessage(msg);
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }

  DateTime getRecentHistoryDate() {
    return _aqData!.data.last.time;
  }

  bool get isLoading => _isLoading;
  AqChartData? get aqData => _aqData;
}
