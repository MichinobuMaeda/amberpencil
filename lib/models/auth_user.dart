import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';

class AuthUser {
  final String uid;
  final String? displayName;
  final String? email;
  final bool emailVerified;

  AuthUser({
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
  bool operator ==(Object other) =>
      other is AuthUser &&
      other.uid == uid &&
      other.displayName == displayName &&
      other.email == email &&
      other.emailVerified == emailVerified;

  @override
  int get hashCode => hashValues(
        uid,
        displayName,
        email,
        emailVerified,
      );
}
