import 'package:flutter/foundation.dart';
import 'package:firebase_auth/firebase_auth.dart';
import '../models/auth_user.dart';
import '../utils/platform_web.dart';
import 'service_provider.dart';

const String reauthenticateParam = '?reauthenticate=yes';

class AuthService extends ServiceProvider<AuthUser> {
  final FirebaseAuth _auth;
  String? _url;

  AuthService(FirebaseAuth auth, String deepLink)
      : _auth = auth,
        super('auth') {
    debugPrint(deepLink);

    if (auth.isSignInWithEmailLink(deepLink)) {
      final String? email = loadSignInEmail();
      debugPrint('sing-in: $email');
      if (email != null) {
        auth.signInWithEmailLink(email: email, emailLink: deepLink);
        if (deepLink.contains(reauthenticateParam)) {
          saveReauthMode();
        }
      }
    }

    auth.authStateChanges().listen((User? user) async {
      debugPrint('authStateChanges ${user?.uid}');
      final authUser = user == null ? null : AuthUser.fromUser(user);
      if (data != authUser) {
        update(authUser);
      }
    });
  }

  set url(String val) {
    _url = val;
  }

  Future<void> reload() async {
    await _auth.currentUser?.reload();
    final User? user = _auth.currentUser;
    final authUser = user == null ? null : AuthUser.fromUser(user);
    if (data != authUser) {
      update(authUser);
    }
  }

  Future<void> signInWithEmailAndPassword(
    String email,
    String password,
  ) async {
    await _auth.signInWithEmailAndPassword(
      email: email,
      password: password,
    );
  }

  Future<void> sendSignInLinkToEmail(String email) async {
    await _auth.sendSignInLinkToEmail(
      email: email,
      actionCodeSettings: ActionCodeSettings(
        url: _url!,
        handleCodeInApp: true,
      ),
    );
    saveSignInEmail(email);
  }

  Future<void> sendEmailVerification() async {
    await reload();
    await _auth.currentUser!.sendEmailVerification();
  }

  Future<void> reauthenticateWithEmail() async {
    await reload();
    final String email = _auth.currentUser!.email!;
    await _auth.sendSignInLinkToEmail(
      email: email,
      actionCodeSettings: ActionCodeSettings(
        url: '${_url!}$reauthenticateParam',
        handleCodeInApp: true,
      ),
    );
    saveSignInEmail(email);
  }

  Future<void> reauthenticateWithPassword(String password) async {
    await reload();
    final credential = EmailAuthProvider.credential(
      email: _auth.currentUser!.email!,
      password: password,
    );
    await _auth.currentUser!.reauthenticateWithCredential(credential);
  }

  Future<void> updateMyPassword(String password) async {
    await reload();
    await _auth.currentUser!.updatePassword(password);
  }

  Future<void> signOut() async {
    await reload();
    if (_auth.currentUser != null) {
      await _auth.signOut();
    }
  }
}
