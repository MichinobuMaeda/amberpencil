import 'package:flutter/foundation.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import '../utils/web.dart';
import 'service_provider.dart';
import 'accounts_service.dart';

class AuthData extends AccountData {
  final String? uid;
  final bool emailVerified;
  AuthData()
      : uid = null,
        emailVerified = false,
        super();
  AuthData.fromUserDataAndSnapshot({
    this.uid,
    this.emailVerified = false,
    required DocumentSnapshot<Map<String, dynamic>> snap,
  }) : super.fromSnapshot(snap);
  AuthData.fromAccountData({
    this.uid,
    this.emailVerified = false,
    required AccountData accountData,
  }) : super.from(accountData);
}

class AuthService extends ServiceProvider<AuthData> {
  final FirebaseAuth auth;
  final FirebaseFirestore db;
  User? _user;
  String? _url;

  AuthService(this.auth, this.db, String deepLink) : super(AuthData()) {
    debugPrint(deepLink);
    if (auth.isSignInWithEmailLink(deepLink)) {
      final String? email = loadSignInEmail();
      debugPrint(email);
      if (email != null) {
        auth.signInWithEmailLink(email: email, emailLink: deepLink);
      }
    }

    auth.authStateChanges().listen((User? user) async {
      if (user == null) {
        if (_user != null) {
          // Signed out.
          _user = null;
          notify(AuthData());
        }
      } else if (_user?.uid == null) {
        // Signed in.
        await _getAccountDoc(user);
      } else if (_user?.uid != user.uid) {
        // Suspected to be a program error, unexpected state.
        notify(AuthData());
        await signOut();
      }
      // } else {
      //   // _user?.uid == null && _user?.uid == user.uid
      //   // I have nothing to do.
      // }
    });
  }

  Future<void> _getAccountDoc(User user) async {
    final me = await db.collection('accounts').doc(user.uid).get();
    if (_user?.uid == user.uid) {
      return;
    }
    _user = user;
    if (!me.exists || me.get('valid') == false || me.get('deletedAt') != null) {
      _user = null;
      await signOut();
    } else {
      notify(
        AuthData.fromUserDataAndSnapshot(
          uid: user.uid,
          emailVerified: user.emailVerified,
          snap: me,
        ),
      );
    }
  }

  Future<void> reload() async {
    if (auth.currentUser != null) {
      await auth.currentUser!.reload();
      _user = auth.currentUser;
      notify(AuthData.fromAccountData(
        uid: data.uid,
        emailVerified: _user!.emailVerified,
        accountData: data,
      ));
    }
  }

  Future<void> signInWithEmailAndPassword(String email, String password) async {
    await auth.signInWithEmailAndPassword(email: email, password: password);
  }

  Future<void> sendSignInLinkToEmail(String email) async {
    await auth.sendSignInLinkToEmail(
      email: email,
      actionCodeSettings: ActionCodeSettings(
        url: _url!,
        handleCodeInApp: true,
      ),
    );
    saveSignInEmail(email);
  }

  Future<void> sendEmailVerification() async {
    await _user!.sendEmailVerification();
  }

  Future<void> signOut() async {
    await auth.currentUser?.reload();
    if (auth.currentUser != null) {
      await auth.signOut();
    }
  }

  set url(String? url) {
    _url = url;
  }
}
