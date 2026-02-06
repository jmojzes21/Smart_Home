import 'package:smart_home_core/exceptions.dart';
import 'package:smart_home_core/view_model.dart';

import '../../models/aq_history_data.dart';
import '../services/interfaces/air_quality_service.dart';

class LocalDataPageVm extends ViewModel {
  final IAirQualityService aqService;
  final Function(String message) onShowMessage;

  bool _isLoading = true;
  AqHistoryData? _aqData;

  LocalDataPageVm({required this.aqService, required this.onShowMessage}) {
    refresh();
  }

  Future<void> refresh() async {
    _isLoading = true;
    notifyListeners();

    try {
      _aqData = await aqService.getLocalAq();
      _aqData!.calculateRanges();
    } catch (e) {
      String msg = Exceptions.getMessage(e);
      onShowMessage(msg);
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }

  bool get isLoading => _isLoading;
  AqHistoryData? get aqData => _aqData;
}
