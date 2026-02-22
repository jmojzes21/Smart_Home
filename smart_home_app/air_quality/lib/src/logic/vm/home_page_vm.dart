import 'dart:async';
import 'dart:developer';
import 'package:smart_home_core/models.dart';
import 'package:smart_home_core/view_model.dart';

import '../../models/air_quality.dart';
import '../services/interfaces/air_quality_service.dart';

class HomePageViewModel extends ViewModel {
  final IAirQualityService aqService;
  final Function(String message) onException;

  AirQuality? _airQuality;
  StreamSubscription? _streamSub;

  bool _isLoading = true;

  HomePageViewModel({required this.aqService, required this.onException}) {
    _init();
  }

  Future<void> _init() async {
    try {
      await aqService.startLiveData();
      var stream = aqService.getLiveDataStream();
      _streamSub = stream.listen((aq) {
        _airQuality = aq;
        notifyListeners();
      });
    } catch (e) {
      String msg = Exceptions.getMessage(e);
      log(msg);
      onException(msg);
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }

  bool get isLoading => _isLoading;
  AirQuality? get airQuality => _airQuality;

  @override
  void dispose() {
    _streamSub?.cancel();
    aqService.stopLiveData();
    super.dispose();
  }
}
