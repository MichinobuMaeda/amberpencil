import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import '../models/account.dart';
import '../repositories/accounts_repository.dart';

abstract class ThemeModeEvent {}

class ThemeModeUpdated extends ThemeModeEvent {
  final Account? me;

  ThemeModeUpdated(this.me);
}

class ThemeModeChanged extends ThemeModeEvent {
  final int mode;

  ThemeModeChanged(this.mode);
}

class ThemeModeBloc extends Bloc<ThemeModeEvent, int> {
  final BuildContext _context;
  Account? _me;

  ThemeModeBloc(BuildContext context)
      : _context = context,
        super(0) {
    on<ThemeModeUpdated>((event, emit) {
      _me = event.me;
      emit(_me?.themeMode ?? state);
    });

    on<ThemeModeChanged>((event, emit) {
      if (_me == null) {
        emit(event.mode);
      } else {
        _context.read<AccountsRepository>().updateMe(
          {Account.fieldThemeMode: event.mode},
        );
      }
    });
  }
}
