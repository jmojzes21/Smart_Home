import 'dart:async';
import 'package:smart_home_core/models.dart';
import 'package:smart_home_core/view_model.dart';

import '../../models/air_quality.dart';
import '../services/interfaces/air_quality_service.dart';

class HomePageViewModel extends ViewModel {
  final IAirQualityService aqService;
  final Function(String message) onException;

  var _airQuality = AirQuality.empty();

  bool _isLoading = true;
  Timer? _refreshTimer;

  HomePageViewModel({required this.aqService, required this.onException}) {
    _init();
  }

  bool get isLoading => _isLoading;
  AirQuality get airQuality => _airQuality;

  Future<void> _init() async {
    try {
      await _getAirQuality();
    } catch (e) {
      String msg = Exceptions.getMessage(e);
      onException(msg);
      return;
    }

    _isLoading = false;
    notifyListeners();

    _refreshTimer = Timer.periodic(Duration(seconds: 2), (timer) => _onRefresh());
  }

  Future<void> _getAirQuality() async {
    _airQuality = await aqService.getAirQuality();
    notifyListeners();
  }

  Future<void> _onRefresh() async {
    try {
      await _getAirQuality();
    } catch (e) {
      _refreshTimer?.cancel();
      String msg = Exceptions.getMessage(e);
      onException(msg);
    }
  }

  @override
  void dispose() {
    _refreshTimer?.cancel();
    super.dispose();
  }
}
