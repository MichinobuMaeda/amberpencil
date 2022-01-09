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
      AuthData? newMe = data.uid == null ? null : data;
      if (_me?.id != newMe?.id) {
        _me = newMe;
      }
    } else if (data is List<AccountData>) {
      try {
        _me = data.firstWhere((item) => item.id == _me?.id);
      } catch (e) {
        _me = null;
      }
    }

    if (_me != null) {
      int themeMode = _me!.themeMode;
      if (_selected != themeMode) {
        _selected = themeMode;
        notifyListeners();
      }
    }
  }

  set selected(int val) {
    if (_selected != val) {
      if (_me == null) {
        _selected = val;
        notifyListeners();
      } else {
        accountsService.updateAccountProperties(_me!.id!, {
          "themeMode": val,
        });
      }
    }
  }

  int get selected => _selected;

  ThemeMode get themeMode => _selected == 1
      ? ThemeMode.light
      : _selected == 2
          ? ThemeMode.dark
          : ThemeMode.system;
}
