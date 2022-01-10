import 'package:amberpencil/utils/platform_web.dart';
import 'package:flutter/material.dart';
import '../config/app_info.dart';
import '../config/routes.dart';
import '../models/auth_user.dart';
import '../models/account.dart';
import '../models/conf.dart';
import '../models/app_route.dart';
import '../services/service_listener.dart';
import '../services/conf_service.dart';
import '../services/auth_service.dart';
import '../services/accounts_service.dart';

mixin RouteStateListener {
  setClientState(ClientState clientState) {}
  setRoute(AppRoute appRoute) {}
}

class AppStateProvider extends ChangeNotifier with ServiceListener {
  final ConfService confService;
  final AuthService authService;
  final AccountsService accountsService;
  Conf? _conf;
  bool _autChecked = false;
  AuthUser? _authUser;
  Account? _me;

  DateTime? _reauthedAt;
  ClientState _clientState = initialClientState;
  RouteStateListener? _routeStateListener;

  AppStateProvider(
    this.confService,
    this.authService,
    this.accountsService,
  ) {
    confService.registerListener(this);
    authService.registerListener(this);
    accountsService.registerListener(this);
  }

  @override
  void notify(String key, dynamic data) {
    if (key == confService.key) {
      Conf? prev = _conf;
      _conf = data;
      if (data is Conf) {
        authService.url = _conf!.url;
      }
      if (prev?.id != _conf?.id) {
        updateClientState();
      }
      if (prev != null && _conf != null && prev.version != _conf!.version) {
        notifyListeners();
      }
    } else if (key == authService.key) {
      AuthUser? prev = _authUser;
      _authUser = data;
      if (!_autChecked ||
          prev?.emailVerified != (data as AuthUser?)?.emailVerified) {
        _autChecked = true;
        updateClientState();
      }
      if (_authUser != null) {
        accountsService.subscribe(_authUser!.uid);
      }
    } else if (key == accountsService.key) {
      Account? prev = _me;
      _me = accountsService.me;
      if ((_authUser != null || prev != null) && _me == null) {
        signOut();
      }
      if (prev != _me) {
        notifyListeners();
        updateClientState();
      }
    }
  }

  void clearUserData() {
    _me = null;
    _reauthedAt = null;
    accountsService.unsubscribe();
    updateClientState();
  }

  Future<void> signOut() async {
    clearUserData();
    await authService.signOut();
  }

  Account? get me => _me;

  DateTime? get reauthedAt => _reauthedAt;

  void updateSignedInAt() {
    _reauthedAt = DateTime.now();
    notifyListeners();
  }

  void updateClientState() {
    late ClientState state;
    if (_conf == null || !_autChecked) {
      state = ClientState.loading;
    } else if (_me == null) {
      state = ClientState.guest;
    } else if (_authUser?.emailVerified != true) {
      state = ClientState.pending;
    } else {
      state = ClientState.authenticated;
    }

    if (_clientState != state) {
      _clientState = state;
      _routeStateListener?.setClientState(_clientState);
      if (_clientState == ClientState.authenticated && loadReauthMode()) {
        _reauthedAt = DateTime.now();
        goRoute(AppRoute(name: RouteName.prefs));
      }
    }
  }

  ClientState get clientState => _clientState;

  set routeStateListener(RouteStateListener routeStateListener) {
    _routeStateListener ??= routeStateListener;
  }

  void goRoute(AppRoute appRoute) {
    _routeStateListener?.setRoute(appRoute);
  }

  bool get updateIsAvailable => _conf != null && _conf!.version != version;

  bool get isTest => version == 'for test';
}
