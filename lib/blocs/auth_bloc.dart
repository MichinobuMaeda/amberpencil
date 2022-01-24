import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:firebase_auth/firebase_auth.dart';
import '../models/auth_user.dart';
import 'platform_bloc.dart';
import 'route_bloc.dart';

abstract class AuthEvent {}

class AuthListenStart extends AuthEvent {
  final BuildContext context;

  AuthListenStart(this.context);
}

class AuthUserChanged extends AuthEvent {
  final AuthUser? authUser;

  AuthUserChanged(this.authUser);
}

class AuthUserReloaded extends AuthEvent {}

class AuthUrlChanged extends AuthEvent {
  final String? url;

  AuthUrlChanged(this.url);
}

class AuthBloc extends Bloc<AuthEvent, AuthUser?> {
  static const String reauthenticateParam = '?reauthenticate=yes';

  final FirebaseAuth _auth;
  late PlatformBloc _platformBloc;
  String? _url;

  AuthBloc({
    FirebaseAuth? auth,
  })  : _auth = auth ?? FirebaseAuth.instance,
        super(null) {
    on<AuthListenStart>((event, emit) {
      _platformBloc = event.context.read<PlatformBloc>();

      // Handle deeplink
      if (_auth.isSignInWithEmailLink(_platformBloc.state.deepLink)) {
        final String? email = _platformBloc.state.email;
        if (email != null) {
          signInWithEmailLink(
            email: email,
            emailLink: _platformBloc.state.deepLink,
          );
        }
      }

      // Listen auth status
      _auth.authStateChanges().listen((User? user) {
        event.context.read<RouteBloc>().add(OnAuthStateChecked());
        add(AuthUserChanged(user == null ? null : AuthUser(user)));
      });
    });

    on<AuthUserChanged>((event, emit) {
      emit(event.authUser);
    });

    on<AuthUserReloaded>((event, emit) async {
      await _auth.currentUser?.reload();
      emit(_auth.currentUser == null ? null : AuthUser(_auth.currentUser!));
    });

    on<AuthUrlChanged>((event, emit) {
      _url = event.url;
    });
  }

  Future<void> signInWithEmailLink({
    required String email,
    required String emailLink,
  }) async {
    await _auth.signInWithEmailLink(
      email: email,
      emailLink: emailLink,
    );
    _platformBloc.add(SignedInAtChanged());
  }

  Future<void> signInWithEmailAndPassword(
    String email,
    String password,
    VoidCallback onError,
  ) async {
    try {
      await _auth.signInWithEmailAndPassword(
        email: email,
        password: password,
      );
      _platformBloc.add(SignedInAtChanged());
    } catch (e, s) {
      debugPrint('\n$runtimeType:signInWithEmailAndPassword\n$e\n$s\n');
      onError();
    }
  }

  Future<void> sendSignInLinkToEmail(
    String email,
    VoidCallback onError,
  ) async {
    try {
      await _auth.sendSignInLinkToEmail(
        email: email,
        actionCodeSettings: ActionCodeSettings(
          url: _url!,
          handleCodeInApp: true,
        ),
      );
      _platformBloc.add(SignInEmailChanged(email));
    } catch (e, s) {
      debugPrint('\n$runtimeType:sendSignInLinkToEmail\n$e\n$s\n');
      onError();
    }
  }

  Future<void> sendEmailVerification() async {
    await _auth.currentUser!.sendEmailVerification();
  }

  Future<void> reauthenticateWithEmail() async {
    final String email = _auth.currentUser!.email!;
    await _auth.sendSignInLinkToEmail(
      email: email,
      actionCodeSettings: ActionCodeSettings(
        url: '$_url$reauthenticateParam',
        handleCodeInApp: true,
      ),
    );
    _platformBloc.add(SignInEmailChanged(email));
  }

  Future<void> reauthenticateWithPassword(
    String password,
    VoidCallback onError,
  ) async {
    try {
      final credential = EmailAuthProvider.credential(
        email: _auth.currentUser!.email!,
        password: password,
      );
      await _auth.currentUser!.reauthenticateWithCredential(credential);
      _platformBloc.add(SignedInAtChanged());
    } catch (e, s) {
      debugPrint('\n$runtimeType:reauthenticateWithPassword\n$e\n$s\n');
      onError();
    }
  }

  Future<void> updateMyPassword(
    String password,
    VoidCallback onError,
  ) async {
    try {
      await _auth.currentUser!.updatePassword(password);
    } catch (e, s) {
      debugPrint('\n$runtimeType:updateMyPassword\n$e\n$s\n');
      onError();
    }
  }

  Future<void> signOut() async {
    debugPrint('$runtimeType:signOut');
    if (_auth.currentUser != null) {
      await _auth.signOut();
    }
  }
}
