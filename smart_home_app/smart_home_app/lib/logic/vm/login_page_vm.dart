import 'package:flutter/material.dart';
import 'package:smart_home_core/view_model.dart';

import '../services/interfaces/auth_service.dart';

class LoginPageViewModel extends ViewModel {
  final tecUsername = TextEditingController();
  final tecPassword = TextEditingController();

  bool _showPassword = false;

  final IAuthService _authService;

  LoginPageViewModel({required IAuthService authService}) : _authService = authService;

  Future<void> login() async {
    String username = tecUsername.text.trim();
    String password = tecPassword.text.trim();
    await _authService.login(username, password);
  }

  bool get showPassword => _showPassword;

  set showPassword(bool value) {
    _showPassword = value;
    notifyListeners();
  }

  @override
  void dispose() {
    tecUsername.dispose();
    tecPassword.dispose();
    super.dispose();
  }
}
