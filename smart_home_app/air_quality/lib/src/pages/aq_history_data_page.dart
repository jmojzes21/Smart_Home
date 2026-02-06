import 'package:flutter/material.dart';

import '../widgets/custom_app_bar.dart';

class AqHistoryDataPage extends StatelessWidget {
  const AqHistoryDataPage({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(appBar: CustomAppBar(title: Text('Povijesni podaci')));
  }
}
