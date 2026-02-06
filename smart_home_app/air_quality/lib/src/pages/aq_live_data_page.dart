import 'package:flutter/material.dart';

import '../widgets/custom_app_bar.dart';

class AqLiveDataPage extends StatelessWidget {
  const AqLiveDataPage({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(appBar: CustomAppBar(title: Text('Uživo podaci')));
  }
}
