import 'package:flutter/material.dart';
import '../services/service_listener.dart';
import '../services/auth_service.dart';
import '../services/accounts_service.dart';

class ThemeModeProvider extends ChangeNotifier with ServiceListener {
  final AuthService authService;
  final AccountsService accountsService;
  AccountData? _me;
  int _selected = 0;

  ThemeModeProvider(
    this.authService,
    this.accountsService,
  ) {
    authService.registerListener(this);
    accountsService.registerListener(this);
  }

  @override
  void notify(dynamic data) {
    if (data is AuthData) {
      _me = data.uid == null ? null : data;
    } else if (data is List<AccountData>) {
      try {
        _me = data.firstWhere((item) => item.id == _me?.id);
      } catch (e) {
        _me = null;
      }
    }
    selected = _me?.themeMode ?? 0;
  }

  set selected(int val) {
    if (_selected != val) {
      _selected = val;
      notifyListeners();
    }
  }

  int get selected => _selected;

  ThemeMode get themeMode => _me?.themeMode == 1
      ? ThemeMode.light
      : _me?.themeMode == 2
          ? ThemeMode.dark
          : ThemeMode.system;
}
