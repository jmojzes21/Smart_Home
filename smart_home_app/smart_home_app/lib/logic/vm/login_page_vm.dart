import 'package:flutter/material.dart';
import 'package:smart_home_core/models.dart';
import 'package:smart_home_core/view_model.dart';

import '../services/interfaces/auth_service.dart';

class LoginPageViewModel extends ViewModel {
  final tecHostname = TextEditingController();
  final tecUsername = TextEditingController();
  final tecPassword = TextEditingController();

  bool _isLoading = true;
  bool _showPassword = false;
  bool _stayLoggedIn = false;

  final IAuthService _authService;

  final VoidCallback openHomePage;

  LoginPageViewModel({required IAuthService authService, required this.openHomePage}) : _authService = authService {
    tecUsername.text = AppContext.instance.backendHostname;
    _loadSession();
  }

  Future<void> login() async {
    String hostname = tecHostname.text.trim();
    String username = tecUsername.text.trim();
    String password = tecPassword.text.trim();

    await _authService.login(hostname, username, password, stayLoggedIn);
    openHomePage();
  }

  Future<void> _loadSession() async {
    bool success = await _authService.loadSession();
    if (success) {
      openHomePage();
    } else {
      _isLoading = false;
      notifyListeners();
    }
  }

  bool get isLoading => _isLoading;
  bool get showPassword => _showPassword;
  bool get stayLoggedIn => _stayLoggedIn;

  set showPassword(bool value) {
    _showPassword = value;
    notifyListeners();
  }

  set stayLoggedIn(bool value) {
    _stayLoggedIn = value;
    notifyListeners();
  }

  @override
  void dispose() {
    tecHostname.dispose();
    tecUsername.dispose();
    tecPassword.dispose();
    super.dispose();
  }
}
