import 'package:amberpencil/models/app_state_model.dart';
import 'package:firebase_auth/firebase_auth.dart';
import '../models/app_state_model.dart';

class AuthService {
  AppStateModel? _appStateModel;
  User? _user;

  void _listen() {
    if (_appStateModel != null) {
      FirebaseAuth.instance.authStateChanges().listen((User? user) {
        _user = user;
        _appStateModel!.authChecked = true;
        if (_user == null) {
          _appStateModel!.uid = null;
          _appStateModel!.verified = false;
        } else {
          _appStateModel!.uid = _user!.uid;
          _appStateModel!.verified = _user!.emailVerified;
        }
      });
    }
  }

  Future<void> reload() async {
    if (_user != null) {
      await _user!.reload();
      _appStateModel!.verified = _user!.emailVerified;
    }
  }

  set appStateModel(AppStateModel appStateModel) {
    if (_appStateModel == null) {
      _appStateModel = appStateModel;
      _listen();
    }
  }
}
