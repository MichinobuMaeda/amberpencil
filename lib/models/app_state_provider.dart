import 'package:flutter/material.dart';
import 'package:flutter/scheduler.dart';
import '../config/routes.dart';
import '../services/service_listener.dart';
import '../services/sys_service.dart';
import '../services/auth_service.dart';
import '../services/accounts_service.dart';
import 'app_route.dart';

class AppStateProvider extends ChangeNotifier with ServiceListener {
  final SysService sysService;
  final AuthService authService;
  final AccountsService accountsService;
  SysData? _sysData;
  bool _authChecked = false;
  bool _verified = false;
  AccountData? _me;
  List<AppRoute> _routes = [AppRoute(name: loadingRouteName)];

  AppStateProvider(
    this.sysService,
    this.authService,
    this.accountsService,
  ) {
    sysService.registerListener(this);
    authService.registerListener(this);
    accountsService.registerListener(this);
  }

  @override
  void notify(dynamic data) {
    if (data is SysData) {
      if (version != data.version || url != data.url) {
        _sysData = data;
        authService.url = url;
        notifyListeners();
      }
    } else if (data is AuthData) {
      if (!authChecked ||
          _me?.id != data.uid ||
          verified != data.emailVerified) {
        _authChecked = true;
        _verified = data.emailVerified;
        _me = data.uid == null ? null : data;

        if (data.uid == null) {
          if (accountsService.subscribed) {
            clearUserData();
          }
        } else {
          if (!accountsService.subscribed) {
            accountsService.subscribe(data);
          }
        }
        notifyListeners();
      }
    } else if (data is List<AccountData>) {
      if (data.isEmpty) {
        if (_me != null) {
          clearUserData();
          authService.signOut();
        }
      } else {
        final me = data.where((item) => item.id == _me?.id);
        if (me.isEmpty) {
          // Suspected to be a program error, unexpected state.
          clearUserData();
          authService.signOut();
        } else {
          _me = me.first;
        }
      }
    }
  }

  void clearUserData() {
    _me = null;
    accountsService.unsubscribe();
  }

  String? get version => _sysData?.version;
  String? get url => _sysData?.url;
  bool get authChecked => _authChecked;
  bool get verified => _verified;

  AccountData? get me => _me;

  bool get isLoading => _sysData?.version == null || !_authChecked;
  bool get isGuest => !isLoading && _me == null;
  bool get isPending => !isLoading && _me != null && !verified;
  bool get isAuthenticated => !isLoading && _me != null && verified;

  ThemeMode get themeMode => (_me?.themeMode == 2 ||
          (_me?.themeMode == 3 &&
              SchedulerBinding.instance!.window.platformBrightness ==
                  Brightness.dark))
      ? ThemeMode.dark
      : ThemeMode.light;

  bool guard(AppRoute appRoute) {
    AppRoute prev = _routes.last;

    AppRoute top() {
      if (isLoading) {
        return AppRoute(name: loadingRouteName);
      } else if (isGuest) {
        return AppRoute(name: signinRouteName);
      } else if (isPending) {
        return AppRoute(name: verifyRouteName);
      } else {
        return AppRoute(name: homeRouteName);
      }
    }

    if (appRoute.top) {
      _routes = [top()];
    } else {
      _routes = [top(), appRoute];
    }

    return prev != _routes.last;
  }

  List<AppRoute> get routes => _routes;

  void goRoute(AppRoute appRoute) {
    if (guard(appRoute)) {
      notifyListeners();
    }
  }
}
