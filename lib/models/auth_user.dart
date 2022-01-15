import 'package:equatable/equatable.dart';
import 'package:firebase_auth/firebase_auth.dart';

class AuthUser extends Equatable {
  final String uid;
  final String? displayName;
  final String? email;
  final bool emailVerified;

  const AuthUser({
    required this.uid,
    required this.displayName,
    required this.email,
    required this.emailVerified,
  });

  AuthUser.fromUser(User user)
      : uid = user.uid,
        displayName = user.displayName,
        email = user.email,
        emailVerified = user.emailVerified;

  @override
  List<Object?> get props => [
        uid,
        displayName,
        email,
        emailVerified,
      ];
}
