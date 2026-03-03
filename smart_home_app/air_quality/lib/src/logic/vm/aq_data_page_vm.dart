import 'dart:io';

import 'package:smart_home_core/exceptions.dart';
import 'package:smart_home_core/view_model.dart';

import '../../models/aq_chart_data.dart';
import '../helpers/aq_history_csv_converter.dart';
import '../services/interfaces/air_quality_service.dart';

class AirQualityDataPageViewModel extends ViewModel {
  final IAirQualityService aqService;
  final Function(String message) onShowMessage;

  DateTime? _historyStartDate;
  DateTime? _historyEndDate;

  bool _isLoading = false;
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

  Future<void> showHistoryData() async {
    try {
      if (_historyStartDate == null) {
        throw AppException('Odaberite počeni datum!');
      }

      if (_historyEndDate == null) {
        throw AppException('Odaberite završni datum!');
      }

      if (_historyStartDate!.compareTo(_historyEndDate!) > 0) {
        DateTime t = _historyStartDate!;
        _historyStartDate = _historyEndDate;
        _historyEndDate = t;
      }

      _isLoading = true;
      notifyListeners();

      var data = await aqService.getHistory(_historyStartDate!, _historyEndDate!);
      _aqData = AqChartData(data, tooltipShowDate: true);
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

  DateTime? get historyStartDate => _historyStartDate;
  DateTime? get historyEndDate => _historyEndDate;

  void setHistoryStartDate(DateTime? value) {
    _historyStartDate = value;
    notifyListeners();
  }

  void setHistoryEndDate(DateTime? value) {
    _historyEndDate = value;
    notifyListeners();
  }

  void setHistoryRange(DateTime start, DateTime end) {
    _historyStartDate = start;
    _historyEndDate = end;
    notifyListeners();
  }

  bool get isLoading => _isLoading;
  AqChartData? get aqData => _aqData;
}
