import 'package:flutter/material.dart';
import '../models/account.dart';
import '../services/service_listener.dart';
import '../services/accounts_service.dart';

class ThemeModeProvider extends ChangeNotifier with ServiceListener {
  final AccountsService accountsService;
  Account? _me;
  int _selected = 0;

  ThemeModeProvider(
    this.accountsService,
  ) {
    accountsService.registerListener(this);
  }

  @override
  void notify(String key, dynamic data) {
    if (key == accountsService.key) {
      _me = accountsService.me;
      if (data is List<Account> && _me != null && _selected != _me!.themeMode) {
        _selected = _me!.themeMode;
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
        accountsService.updateAccountProperties(_me!.id, {
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
