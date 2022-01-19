import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import '../blocs/route_bloc.dart';
import '../models/auth_user.dart';
import '../models/account.dart';
import '../repositories/accounts_repository.dart';
import '../repositories/auth_repository.dart';
import '../repositories/conf_repository.dart';
import 'theme_mode_bloc.dart';

class MyAccountStatus {
  final AuthUser? authUser;
  final Account? me;

  MyAccountStatus(this.authUser, this.me);
}

abstract class MeEvent {}

class OnSignedIn extends MeEvent {
  final AuthUser authUser;

  OnSignedIn(this.authUser);
}

class OnSignedOut extends MeEvent {}

class OnAuthUserReloaded extends MeEvent {
  final AuthUser? authUser;

  OnAuthUserReloaded(this.authUser);
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
    on<OnSignedIn>((event, emit) async {
      Account? me =
          await context.read<AccountsRepository>().restoreMe(event.authUser);
      if (me == null || !me.valid || me.deletedAt != null) {
        add(OnSingOutRequired());
      } else if (state.me != null &&
          (state.me!.id != me.id ||
              state.me!.admin != me.admin ||
              state.me!.tester != me.tester)) {
        add(OnSingOutRequired());
      } else {
        emit(MyAccountStatus(event.authUser, me));
        context.read<AccountsRepository>().subscribe(me);
      }
    });

    on<OnSignedOut>((event, emit) {
      emit(MyAccountStatus(null, null));
      discardAllUserData(context);
    });

    on<OnAuthUserReloaded>((event, emit) {
      if (event.authUser?.uid != state.me?.id) {
        add(OnSingOutRequired());
      } else {
        emit(MyAccountStatus(event.authUser, state.me));
      }
    });

    on<OnAccountsUpdated>((event, emit) {
      try {
        Account me = (event.accounts ?? []).singleWhere(
          (account) => account.id == state.me?.id,
        );
        if (state.authUser?.uid != me.id) {
          add(OnSingOutRequired());
        } else if (!me.valid || me.deletedAt != null) {
          add(OnSingOutRequired());
        } else if (state.me != null &&
            (state.me!.id != me.id ||
                state.me!.admin != me.admin ||
                state.me!.tester != me.tester)) {
          add(OnSingOutRequired());
        } else {
          emit(MyAccountStatus(state.authUser, me));
        }
      } catch (e) {
        if (state.authUser != null) {
          add(OnSingOutRequired());
        }
      }
    });

    on<OnSingOutRequired>((event, emit) async {
      emit(MyAccountStatus(null, null));
      discardAllUserData(context);
      await context.read<AuthRepository>().signOut();
    });
  }

  void discardAllUserData(BuildContext context) {
    context.read<AccountsRepository>().unsubscribe();
  }

  @override
  void onChange(Change<MyAccountStatus> change) {
    super.onChange(change);
    _context.read<RouteBloc>().add(OnMyAccountUpdated(
          change.nextState.authUser,
          change.nextState.me,
        ));
    _context.read<ThemeModeBloc>().add(ThemeModeUpdated(change.nextState.me));
    if (change.nextState.me != null) {
      _context.read<ConfRepository>().subscribe(change.nextState.me!);
      // TODO: GroupsRepository
      // TODO: PeopleRepository
    } else {
      _context.read<ConfRepository>().unsubscribe();
      // TODO: GroupsRepository
      // TODO: PeopleRepository
    }
  }
}
