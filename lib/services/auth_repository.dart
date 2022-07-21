import 'package:flutter/foundation.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:uni_links/uni_links.dart';

import '../models/auth_user.dart';
import 'providers.dart';

class AuthRepo {
  final FirebaseAuth _auth;

  AuthRepo({FirebaseAuth? instance})
      : _auth = instance ?? FirebaseAuth.instance;

  void listen(
    WidgetRef ref,
  ) async {
    final String? initialLink = await getInitialLink();
    debugPrint('${DateTime.now().toIso8601String()} initialLink: $initialLink');

    if (initialLink != null && _auth.isSignInWithEmailLink(initialLink)) {
      //   final String? email = _platformBloc.state.email;
      //   if (email != null) {
      //     await _auth.signInWithEmailLink(
      //       email: email,
      //       emailLink: initialLink,
      //     );
      //     _platformBloc.add(SignedInAtChanged());
      //   }
    }

    _auth.authStateChanges().listen((User? user) {
      ref.read(authProvider.notifier).state = AuthUser.fromUser(user);
    });
  }

  Future<void> signInWithEmailAndPassword({
    required String email,
    required String password,
  }) async {
    _auth.signInWithEmailAndPassword(email: email, password: password);
  }

  Future<void> signOut() async {
    _auth.signOut();
  }
}
