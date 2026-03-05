import 'dart:async';
import 'dart:collection';
import 'dart:io';

import 'package:smart_home_core/exceptions.dart';
import 'package:smart_home_core/view_model.dart';

import '../../models/air_quality.dart';
import '../../models/aq_chart_data.dart';
import '../../models/aq_history.dart';
import '../helpers/aq_history_csv_converter.dart';
import '../services/interfaces/air_quality_service.dart';

class AirQualityDataPageViewModel extends ViewModel {
  final IAirQualityService aqService;
  final Function(String message) onShowMessage;

  DateTime? _historyStartDate;
  DateTime? _historyEndDate;

  bool _isLoading = false;
  AqChartData? _aqData;

  StreamSubscription<AirQuality>? _liveAqSub;
  final Queue<AqHistoryChartData> _liveAqQueue = ListQueue();
  final int _liveAqQueueMaxSize = 200;

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

  Future<void> showLiveData() async {
    try {
      _isLoading = true;
      notifyListeners();

      await aqService.startLiveData();
      _liveAqSub = aqService.getLiveDataStream().listen((data) => _onLiveData(data));
    } catch (e) {
      String msg = Exceptions.getMessage(e);
      onShowMessage(msg);
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }

  void _onLiveData(AirQuality aq) {
    var aqh = AqHistoryChartData(_liveAqToHistory(aq));

    if (_liveAqQueue.length >= _liveAqQueueMaxSize) {
      _liveAqQueue.removeFirst();
    }
    _liveAqQueue.addLast(aqh);

    _aqData = AqChartData(_liveAqQueue.toList(), tooltipShowDate: false);
    notifyListeners();
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

  @override
  void dispose() {
    _liveAqSub?.cancel();
    _liveAqSub = null;
    super.dispose();
  }

  AqHistory _liveAqToHistory(AirQuality aq) {
    return AqHistory(
      time: DateTime.now(),
      temperature: AqMetrics.live(aq.temperature),
      humidity: AqMetrics.live(aq.humidity),
      pressure: AqMetrics.live(aq.pressure),
      pm25: AqMetrics.live(aq.pm25.toDouble()),
    );
  }
}
