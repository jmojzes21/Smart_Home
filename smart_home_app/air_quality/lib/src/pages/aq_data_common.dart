import 'package:file_picker/file_picker.dart';
import 'package:flutter/widgets.dart';

import '../logic/vm/aq_data_page_vm.dart';

void saveAirQualityHistoryData(BuildContext context, AirQualityDataPageViewModel model) async {
  var fileName = model.aqData!.data.first.time.toIso8601String();
  fileName = fileName.replaceAll('T', ' ').replaceAll(':', '-');
  fileName = '$fileName.csv';

  String? path = await FilePicker.platform.saveFile(
    lockParentWindow: true,
    type: FileType.custom,
    allowedExtensions: ['csv'],
    fileName: fileName,
  );
  if (path == null) return;

  if (!path.endsWith('.csv')) {
    path = '$path.csv';
  }

  model.saveData(path);
}
