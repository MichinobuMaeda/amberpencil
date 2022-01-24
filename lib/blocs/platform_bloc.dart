import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:equatable/equatable.dart';
import 'package:universal_html/html.dart' as html;
import 'package:shared_preferences/shared_preferences.dart';

class PlatformStatue extends Equatable {
  final String deepLink;
  final int themeMode;
  final String email;
  final int signedInAt;

  const PlatformStatue({
    required this.deepLink,
    required this.themeMode,
    required this.email,
    required this.signedInAt,
  });

  PlatformStatue copyWith({
    int? themeMode,
    String? email,
    int? signedInAt,
  }) =>
      PlatformStatue(
        deepLink: deepLink,
        themeMode: themeMode ?? this.themeMode,
        email: email ?? this.email,
        signedInAt: signedInAt ?? this.signedInAt,
      );

  @override
  List<Object?> get props => [
        deepLink,
        themeMode,
        email,
        signedInAt,
      ];
}

abstract class PlatformEvent {}

class ThemeModeChanged extends PlatformEvent {
  final int themeMode;

  ThemeModeChanged(this.themeMode);
}

class SignInEmailChanged extends PlatformEvent {
  final String email;

  SignInEmailChanged(this.email);
}

class SignedInAtChanged extends PlatformEvent {
  SignedInAtChanged();
}

class AppReloaded extends PlatformEvent {
  AppReloaded();
}

class PlatformBloc extends Bloc<PlatformEvent, PlatformStatue> {
  static const keyThemeMode = 'themeMode';
  static const keyEmail = 'email';
  static const keySignedInAt = 'signedInAt';

  final html.Window _window;
  final SharedPreferences _localPreferences;

  PlatformBloc(
    html.Window window,
    SharedPreferences localPreferences,
  )   : _window = window,
        _localPreferences = localPreferences,
        super(
          PlatformStatue(
            deepLink: window.location.href,
            themeMode: localPreferences.getInt(keyThemeMode) ?? 0,
            email: localPreferences.getString(keyEmail) ?? '',
            signedInAt: localPreferences.getInt(keySignedInAt) ?? 0,
          ),
        ) {
    on<ThemeModeChanged>((event, emit) {
      _localPreferences.setInt(keyThemeMode, event.themeMode);
      emit(state.copyWith(themeMode: event.themeMode));
    });

    on<SignInEmailChanged>((event, emit) {
      _localPreferences.setString(keyEmail, event.email);
      emit(state.copyWith(email: event.email));
    });

    on<SignedInAtChanged>((event, emit) {
      int sinedInAt = DateTime.now().microsecondsSinceEpoch;
      _localPreferences.setInt(keySignedInAt, sinedInAt);
      emit(state.copyWith(signedInAt: sinedInAt));
    });

    on<AppReloaded>((event, emit) {
      _window.location.reload();
    });
  }
}
