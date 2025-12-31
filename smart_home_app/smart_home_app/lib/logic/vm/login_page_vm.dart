import 'package:flutter/material.dart';
import 'package:smart_home_core/models.dart';
import 'package:smart_home_core/view_model.dart';

import '../services/interfaces/auth_service.dart';

class LoginPageViewModel extends ViewModel {
  final tecHostname = TextEditingController();
  final tecUsername = TextEditingController();
  final tecPassword = TextEditingController();

  bool _isLoading = true;
  bool _showFullLoading = true;

  bool _showPassword = false;
  bool _stayLoggedIn = false;

  final IAuthService authService;
  final VoidCallback onOpenHomePage;
  final Function(String message) onShowMessage;

  LoginPageViewModel({required this.authService, required this.onShowMessage, required this.onOpenHomePage}) {
    tecHostname.text = AppContext.instance.backendHostname;
    _init();
  }

  Future<void> login() async {
    String hostname = tecHostname.text.trim();
    String username = tecUsername.text.trim();
    String password = tecPassword.text.trim();

    _isLoading = true;
    notifyListeners();

    try {
      await authService.login(hostname, username, password, stayLoggedIn);
      onOpenHomePage();
    } catch (e) {
      _isLoading = false;
      notifyListeners();

      String msg = Exceptions.getMessage(e);
      onShowMessage(msg);
    }
  }

  Future<void> _init() async {
    await AppContext.instance.init();
    await _loadSession();
  }

  Future<void> _loadSession() async {
    bool success = await authService.loadSession();
    if (success) {
      onOpenHomePage();
    } else {
      _showFullLoading = false;
      _isLoading = false;
      notifyListeners();
    }
  }

  bool get isLoading => _isLoading;
  bool get showFullLoading => _showFullLoading;
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
