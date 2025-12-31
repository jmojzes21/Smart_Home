import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../logic/vm/profile_page_vm.dart';

class ProfilePage extends StatelessWidget {
  const ProfilePage({super.key});

  @override
  Widget build(BuildContext context) {
    return ChangeNotifierProvider(
      create: (context) => ProfilePageViewModel(),
      child: Consumer<ProfilePageViewModel>(builder: (context, model, child) => buildBody(context, model)),
    );
  }

  Widget buildBody(BuildContext context, ProfilePageViewModel model) {
    return SingleChildScrollView(
      child: Padding(
        padding: EdgeInsets.all(20),
        child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [Placeholder()]),
      ),
    );
  }
}
