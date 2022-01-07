import 'package:flutter/material.dart';
import '../services/service_listener.dart';
import '../services/conf_service.dart';
import '../services/auth_service.dart';
import '../services/accounts_service.dart';
import 'app_info.dart';

enum ClientState { loading, guest, pending, authenticated }

const ClientState initialClientState = ClientState.loading;

class AppStateProvider extends ChangeNotifier with ServiceListener {
  final AppStaticInfo appStaticInfo;
  final ConfService confService;
  final AuthService authService;
  final AccountsService accountsService;
  String? _version;
  String? _url;
  bool _authChecked = false;
  bool _verified = false;
  DateTime? _reauthedAt;
  AccountData? _me;
  ClientState _clientState = initialClientState;

  AppStateProvider(
    this.appStaticInfo,
    this.confService,
    this.authService,
    this.accountsService,
  ) {
    confService.registerListener(this);
    authService.registerListener(this);
    accountsService.registerListener(this);
  }

  @override
  void notify(dynamic data) {
    if (data is ConfData) {
      version = data.version;
      url = data.url;
    } else if (data is AuthData) {
      authChecked = true;
      verified = data.emailVerified;
      AccountData? newMe = data.uid == null ? null : data;
      if (me != newMe) {
        me = newMe;
        notifyListeners();
      }
    } else if (data is List<AccountData>) {
      try {
        AccountData? newMe = data.firstWhere((item) => item.id == _me?.id);
        if (me != newMe) {
          me = newMe;
          notifyListeners();
        }
      } catch (e) {
        me = null;
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

  set version(String? val) {
    if (_version != val) {
      _version = val;
      if (!updateClientState()) {
        notifyListeners();
      }
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
          signOut();
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

  DateTime? get reauthedAt => _reauthedAt;

  void updateSignedInAt() {
    _reauthedAt = DateTime.now();
    debugPrint('signedInAt: $_reauthedAt');
    notifyListeners();
  }

  bool updateClientState() {
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
      notifyListeners();
      return true;
    }
    return false;
  }

  ClientState get clientState => _clientState;

  bool updateIsAvailable() =>
      version != null && version != appStaticInfo.version;

  bool get test => appStaticInfo.version == 'for test';
}
