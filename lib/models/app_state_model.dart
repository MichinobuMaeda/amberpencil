import 'package:flutter/foundation.dart';
import '../services/sys_service.dart';
import '../services/auth_service.dart';

class AppStateModel extends ChangeNotifier {
  final SysService sysService;
  final AuthService authService;
  String? _version;
  String? url;
  bool _authChecked = false;
  String? _uid;
  bool _verified = false;
  bool _admin = false;
  bool _tester = false;

  AppStateModel(this.sysService, this.authService) {
    sysService.appStateModel = this;
    authService.appStateModel = this;
  }

  set version(String? val) {
    if (_version != val) {
      _version = val;
      notifyListeners();
    }
  }

  set authChecked(bool val) {
    if (_authChecked != val) {
      _authChecked = val;
      notifyListeners();
    }
  }

  set uid(String? val) {
    if (_uid != val) {
      _uid = val;
      notifyListeners();
    }
  }

  set verified(bool val) {
    if (_verified != val) {
      _verified = val;
      notifyListeners();
    }
  }

  set admin(bool val) {
    if (_admin != val) {
      _admin = val;
      notifyListeners();
    }
  }

  set tester(bool val) {
    if (_tester != val) {
      _tester = val;
      notifyListeners();
    }
  }

  String? get version => _version;
  bool get authChecked => _authChecked;
  String? get uid => _uid;
  bool get verified => _verified;
  bool get admin => _admin;
  bool get tester => _tester;

  bool get isLoading => _version == null || !_authChecked;
  bool get isGuest => !isLoading && _uid == null;
  bool get isPending => !isLoading && _uid != null && !verified;
  bool get isAuthenticated => !isLoading && _uid != null && verified;
}
