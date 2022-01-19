import 'package:flutter/widgets.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import '../blocs/route_bloc.dart';
import '../models/auth_user.dart';
import '../models/account.dart';
import '../repositories/accounts_repository.dart';
import '../repositories/auth_repository.dart';
import '../repositories/conf_repository.dart';
import '../repositories/groups_repository.dart';
import 'theme_mode_bloc.dart';

class MyAccountStatus {
  final AuthUser? authUser;
  final Account? me;

  MyAccountStatus(this.authUser, this.me);
}

abstract class MeEvent {}

class OnAuthUserUpdated extends MeEvent {
  final AuthUser? authUser;

  OnAuthUserUpdated(this.authUser);
}

class OnAccountsUpdated extends MeEvent {
  final List<Account>? accounts;

  OnAccountsUpdated(this.accounts);
}

class OnSingOutRequired extends MeEvent {}

class MyAccountBloc extends Bloc<MeEvent, MyAccountStatus> {
  final BuildContext _context;

  MyAccountBloc(BuildContext context)
      : _context = context,
        super(MyAccountStatus(null, null)) {
    on<OnAuthUserUpdated>((event, emit) async {
      validateAndEmitState(
        event.authUser,
        event.authUser == null
            ? null
            : event.authUser?.uid == state.me?.id
                ? state.me
                : await context
                    .read<AccountsRepository>()
                    .restoreMe(event.authUser!),
        emit,
      );
      _context.read<RouteBloc>().add(OnAuthStateChecked());
    });

    on<OnAccountsUpdated>((event, emit) {
      try {
        validateAndEmitState(
          state.authUser,
          state.authUser == null
              ? null
              : (event.accounts ?? []).singleWhere(
                  (account) => account.id == state.authUser?.uid,
                ),
          emit,
        );
      } catch (e) {
        emit(MyAccountStatus(null, null));
      }
    });

    on<OnSingOutRequired>((event, emit) async {
      emit(MyAccountStatus(null, null));
    });
  }

  void validateAndEmitState(
    AuthUser? authUser,
    Account? me,
    Emitter emit,
  ) {
    if (validateState(authUser, me)) {
      emit(MyAccountStatus(authUser, me));
    } else {
      emit(MyAccountStatus(null, null));
    }
  }

  bool validateState(
    AuthUser? authUser,
    Account? me,
  ) =>
      (authUser == null && me == null) ||
      (authUser?.uid == me?.id &&
          (me?.valid ?? false) &&
          me?.deletedAt == null &&
          (state.me == null ||
              (state.me?.admin == me?.admin &&
                  state.me?.tester == me?.tester)));

  @override
  Future<void> onChange(
    Change<MyAccountStatus> change,
  ) async {
    _context.read<RouteBloc>().add(
          OnMyAccountUpdated(
            change.nextState.authUser,
            change.nextState.me,
          ),
        );
    _context.read<ThemeModeBloc>().add(
          ThemeModeUpdated(
            change.nextState.me,
          ),
        );

    if (change.nextState.me != null) {
      if (change.currentState.me == null) {
        restoreAllUserData(change.nextState.me!);
      }
    } else {
      if (change.currentState.me != null) {
        await discardAllUserData();
        await _context.read<AuthRepository>().signOut();
      }
    }

    super.onChange(change);
  }

  void restoreAllUserData(Account me) {
    _context.read<AccountsRepository>().subscribe(me);
    _context.read<ConfRepository>().subscribe(me);
    _context.read<GroupsRepository>().subscribe(me);
  }

  Future<void> discardAllUserData() async {
    await _context.read<GroupsRepository>().unsubscribe();
    await _context.read<ConfRepository>().unsubscribe();
    await _context.read<AccountsRepository>().unsubscribe();
  }
}
