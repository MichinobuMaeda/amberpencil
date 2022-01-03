import 'package:flutter/material.dart';
import '../config/routes.dart';
import '../services/service_listener.dart';
import '../services/sys_service.dart';
import '../services/auth_service.dart';
import '../services/accounts_service.dart';
import 'app_info.dart';
import 'app_route.dart';

mixin RouteStateListener {
  setClientState(ClientState clientState) {}
  setRoute(AppRoute appRoute) {}
}

class AppStateProvider extends ChangeNotifier with ServiceListener {
  final AppInfo appInfo;
  final SysService sysService;
  final AuthService authService;
  final AccountsService accountsService;
  String? _version;
  String? _url;
  bool _authChecked = false;
  bool _verified = false;
  AccountData? _me;
  // List<AppRoute> _routes = [AppRoute(name: loadingRouteName)];
  ClientState _clientState = initialClientState;
  RouteStateListener? _routeStateListener;

  AppStateProvider(
    this.appInfo,
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
      version = data.version;
      url = data.url;
    } else if (data is AuthData) {
      authChecked = true;
      verified = data.emailVerified;
      me = data.uid == null ? null : data;
    } else if (data is List<AccountData>) {
      try {
        me = data.firstWhere((item) => item.id == _me?.id);
      } catch (e) {
        me = null;
      }
    }
  }

  void clearUserData() {
    _me = null;
    accountsService.unsubscribe();
    updateClientState();
  }

  set version(String? val) {
    if (_version != val) {
      _version = val;
      updateClientState();
    }
  }

  String? get version => _version;

  set url(String? val) {
    if (_url != val) {
      _url = val;
      authService.url = url;
    }
  }

  String? get url => _url;

  set authChecked(bool val) {
    if (_authChecked != val) {
      _authChecked = val;
      updateClientState();
    }
  }

  bool get authChecked => _authChecked;

  set verified(bool? val) {
    if (_verified != val) {
      _verified = val ?? false;
      updateClientState();
    }
  }

  bool get verified => _verified;

  set me(AccountData? val) {
    bool clientStateChanged = _me?.id != val?.id;
    AccountData? prev = _me;
    _me = val;
    if (clientStateChanged) {
      if (_me == null) {
        if (accountsService.subscribed) {
          clearUserData();
        }
        if (prev != null) {
          clearUserData();
          authService.signOut();
        }
      } else {
        if (!accountsService.subscribed) {
          accountsService.subscribe(_me!);
        }
      }
      updateClientState();
    }
  }

  AccountData? get me => _me;

  void updateClientState() {
    late ClientState state;
    if (_version == null || !_authChecked) {
      state = ClientState.loading;
    } else if (_me == null) {
      state = ClientState.guest;
    } else if (!verified) {
      state = ClientState.pending;
    } else {
      state = ClientState.authenticated;
    }

    if (_clientState != state) {
      _clientState = state;
      _routeStateListener?.setClientState(_clientState);
    }
  }

  ClientState get clientState => _clientState;

  set routeStateListener(RouteStateListener routeStateListener) {
    _routeStateListener ??= routeStateListener;
  }

  void goRoute(AppRoute appRoute) {
    _routeStateListener?.setRoute(appRoute);
  }

  bool updateIsAvailable() => version != null && version != appInfo.version;
}
