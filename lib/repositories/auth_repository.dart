import 'package:flutter/foundation.dart';
import 'package:firebase_auth/firebase_auth.dart';
import '../models/auth_user.dart';
import 'platform_repository.dart';

const String reauthenticateParam = '?reauthenticate=yes';
const String emailKey = 'amberpencil_email';
const String signedInAtKey = 'amberpencil_signedInAtKey';

class AuthRepository {
  final FirebaseAuth _auth;
  late void Function(AuthUser?) _listener;
  late PlatformRepository _platformRepository;
  DateTime? _signedInAt;
  String? _url;

  AuthRepository({
    FirebaseAuth? auth,
  }) : _auth = auth ?? FirebaseAuth.instance;

  set url(String? url) {
    _url = url;
  }

  DateTime get signedInAt {
    if (_signedInAt == null) {
      String? saved = _platformRepository.load(signedInAtKey, reset: false);
      int msec = saved == null ? 0 : int.parse(saved);
      _signedInAt = DateTime.fromMillisecondsSinceEpoch(msec);
    }
    return _signedInAt!;
  }

  void setSignedInAt() {
    _signedInAt = DateTime.now();
    _platformRepository.save(
      signedInAtKey,
      _signedInAt!.millisecondsSinceEpoch.toString(),
    );
  }

  void start(
    void Function(AuthUser?) listener,
    PlatformRepository localRepository,
  ) {
    _listener = listener;
    _platformRepository = localRepository;

    // Handle deeplink
    if (_auth.isSignInWithEmailLink(_platformRepository.deepLink)) {
      final String? email = _platformRepository.load(emailKey, reset: true);
      if (email != null) {
        signInWithEmailLink(
          email: email,
          emailLink: _platformRepository.deepLink,
        );
      }
    }

    // Listen auth status
    _auth.authStateChanges().listen((User? user) {
      _listener(
        user == null ? null : AuthUser(user),
      );
    });
  }

  Future<void> reload() async {
    await _auth.currentUser?.reload();
    _listener(
      _auth.currentUser == null ? null : AuthUser(_auth.currentUser!),
    );
  }

  Future<void> signInWithEmailLink({
    required String email,
    required String emailLink,
  }) async {
    await _auth.signInWithEmailLink(
      email: email,
      emailLink: emailLink,
    );
    setSignedInAt();
  }

  Future<void> signInWithEmailAndPassword(
    String email,
    String password,
  ) async {
    await _auth.signInWithEmailAndPassword(
      email: email,
      password: password,
    );
    setSignedInAt();
  }

  Future<void> sendSignInLinkToEmail(String email) async {
    await _auth.sendSignInLinkToEmail(
      email: email,
      actionCodeSettings: ActionCodeSettings(
        url: _url!,
        handleCodeInApp: true,
      ),
    );
    _platformRepository.save(emailKey, email);
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
        url: '$_url$reauthenticateParam',
        handleCodeInApp: true,
      ),
    );
    _platformRepository.save(emailKey, email);
  }

  Future<void> reauthenticateWithPassword(String password) async {
    await reload();
    final credential = EmailAuthProvider.credential(
      email: _auth.currentUser!.email!,
      password: password,
    );
    await _auth.currentUser!.reauthenticateWithCredential(credential);
    setSignedInAt();
  }

  Future<void> updateMyPassword(String password) async {
    await reload();
    await _auth.currentUser!.updatePassword(password);
    await reload();
  }

  Future<void> signOut() async {
    debugPrint('${(AuthRepository).toString()}:signOut');
    if (_auth.currentUser != null) {
      await _auth.signOut();
    }
  }
}
