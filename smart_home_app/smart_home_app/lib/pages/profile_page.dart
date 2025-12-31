import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:provider/provider.dart';
import 'package:smart_home_core/extensions.dart';
import 'package:smart_home_core/widgets.dart';

import '../logic/services/auth_service.dart';
import '../logic/vm/profile_page_vm.dart';

class ProfilePage extends StatelessWidget {
  const ProfilePage({super.key});

  @override
  Widget build(BuildContext context) {
    return ChangeNotifierProvider(
      create: (context) => ProfilePageViewModel(AuthService()),
      child: Consumer<ProfilePageViewModel>(builder: (context, model, child) => buildBody(context, model)),
    );
  }

  Future<void> logout(BuildContext context, ProfilePageViewModel model) async {
    bool logout = await Dialogs.showConfirmDialog(context, 'Jeste li sigurni da se želite odjaviti?');

    if (logout) {
      await model.logout();
      if (!context.mounted) return;
      context.replace('/login');
    }
  }

  Widget buildBody(BuildContext context, ProfilePageViewModel model) {
    var user = model.user;
    return SingleChildScrollView(
      child: Padding(
        padding: EdgeInsets.all(40),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(user.fullName, style: context.textTheme.headlineLarge),
            SizedBox(height: 20),
            TextButton(onPressed: () => logout(context, model), child: Text('Odjavi se')),
          ],
        ),
      ),
    );
  }
}
