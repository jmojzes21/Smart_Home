import 'package:flutter/material.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';
import 'package:go_router/go_router.dart';
import 'package:provider/provider.dart';
import 'package:smart_home_core/widgets.dart';

import '../logic/services/auth_service.dart';
import '../logic/vm/login_page_vm.dart';

class LoginPage extends StatelessWidget {
  const LoginPage({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: Text('Prijava')),
      body: ChangeNotifierProvider(
        create: (context) => LoginPageViewModel(
          authService: AuthService(),
          onShowMessage: (message) {
            if (context.mounted) Dialogs.showSnackBar(context, message);
          },
          onOpenHomePage: () {
            if (context.mounted) context.replace('/');
          },
        ),
        child: Consumer<LoginPageViewModel>(builder: (context, model, child) => buildBody(context, model)),
      ),
    );
  }

  Widget buildBody(BuildContext context, LoginPageViewModel model) {
    if (model.isLoading && model.showFullLoading) {
      return Center(child: CircularProgressIndicator());
    }

    var enableButtons = !model.isLoading;

    return Center(
      child: Padding(
        padding: EdgeInsets.all(40),
        child: ConstrainedBox(
          constraints: BoxConstraints(maxWidth: 400),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              TextField(
                controller: model.tecHostname,
                textInputAction: TextInputAction.next,
                decoration: InputDecoration(
                  label: Text('Naziv poslužitelja'),
                  isDense: true,
                  border: OutlineInputBorder(),
                ),
              ),
              SizedBox(height: 20),
              TextField(
                controller: model.tecUsername,
                textInputAction: TextInputAction.next,
                decoration: InputDecoration(label: Text('Korisničko ime'), isDense: true, border: OutlineInputBorder()),
              ),
              SizedBox(height: 20),
              TextField(
                controller: model.tecPassword,
                obscureText: !model.showPassword,
                textInputAction: TextInputAction.done,
                decoration: InputDecoration(
                  label: Text('Lozinka'),
                  isDense: true,
                  border: OutlineInputBorder(),
                  suffixIcon: IconButton(
                    onPressed: () => model.showPassword = !model.showPassword,
                    icon: !model.showPassword
                        ? FaIcon(FontAwesomeIcons.solidEye)
                        : FaIcon(FontAwesomeIcons.solidEyeSlash),
                  ),
                ),
              ),
              SizedBox(height: 10),
              CheckboxListTile(
                value: model.stayLoggedIn,
                controlAffinity: ListTileControlAffinity.leading,
                onChanged: (value) => model.stayLoggedIn = value ?? false,
                title: Text('Ostanite prijavljeni'),
              ),
              SizedBox(height: 40),
              FilledButton(onPressed: enableButtons ? () => model.login() : null, child: Text('Prijavi se')),
            ],
          ),
        ),
      ),
    );
  }
}
