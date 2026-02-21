import 'package:smart_home_core/exceptions.dart';
import 'package:smart_home_core/view_model.dart';

import '../../models/aq_chart_data.dart';
import '../services/interfaces/air_quality_service.dart';

class LocalDataPageVm extends ViewModel {
  final IAirQualityService aqService;
  final Function(String message) onShowMessage;

  bool _isLoading = true;
  AqChartData? _aqData;

  LocalDataPageVm({required this.aqService, required this.onShowMessage}) {
    refresh();
  }

  Future<void> refresh() async {
    _isLoading = true;
    notifyListeners();

    try {
      _aqData = await aqService.getRecentHistory();
    } catch (e) {
      String msg = Exceptions.getMessage(e);
      onShowMessage(msg);
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }

  bool get isLoading => _isLoading;
  AqChartData? get aqData => _aqData;
}
