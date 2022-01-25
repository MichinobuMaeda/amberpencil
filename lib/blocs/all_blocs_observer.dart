import 'package:flutter/widgets.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import '../blocs/my_account_bloc.dart';
import '../models/account.dart';
import '../models/auth_user.dart';
import '../models/conf.dart';
import 'accounts_bloc.dart';
import 'auth_bloc.dart';
import 'conf_bloc.dart';
import 'groups_bloc.dart';
import 'my_account_bloc.dart';
import 'platform_bloc.dart';
import 'route_bloc.dart';

class AllBlocsObserver extends BlocObserver {
  final BuildContext _context;

  AllBlocsObserver(BuildContext context) : _context = context;

  @override
  void onChange(BlocBase bloc, Change change) {
    if (bloc is ConfBloc) {
      Conf? state = change.nextState;

      _context.read<AuthBloc>().add(
            AuthUrlChanged(state?.url),
          );
      _context.read<RouteBloc>().add(
            OnConfUpdated(state),
          );
    } else if (bloc is MyAccountBloc) {
      MyAccountStatus current = change.currentState;
      MyAccountStatus state = change.nextState;

      _context.read<RouteBloc>().add(
            OnMyAccountUpdated(state),
          );

      // Signed in
      if (current.me == null && state.me != null) {
        restoreAllUserData(state.me!);

        if (_context.read<PlatformBloc>().state.themeMode > 0) {
          _context.read<AccountsBloc>().add(
                MyAccountChanged(
                  Account.fieldThemeMode,
                  _context.read<PlatformBloc>().state.themeMode,
                  () {},
                ),
              );
        }
      }

      // Signed out
      if (current.me != null && state.me == null) {
        discardAllUserData();
      }

      if (state.me != null) {
        if (current.me?.themeMode != state.me!.themeMode &&
            state.me!.themeMode > 0) {
          _context.read<PlatformBloc>().add(
                MyThemeModeUpdated(state.me!.themeMode),
              );
        }
      }
    } else if (bloc is AccountsBloc) {
      List<Account> state = change.nextState;

      _context.read<MyAccountBloc>().add(
            OnAccountsUpdated(state),
          );
    } else if (bloc is AuthBloc) {
      AuthUser? state = change.nextState;

      _context.read<MyAccountBloc>().add(
            OnAuthUserUpdated(state),
          );
    }

    super.onChange(bloc, change);
  }

  void restoreAllUserData(Account me) {
    _context.read<AccountsBloc>().add(
          AccountsSubscribed(me),
        );
    _context.read<ConfBloc>().add(
          ConfSubscribed(me),
        );
    _context.read<GroupsBloc>().add(
          GroupsSubscribed(me),
        );
  }

  Future<void> discardAllUserData() async {
    debugPrint('discardAllUserData()');
    _context.read<GroupsBloc>().add(
          GroupsUnsubscribed(),
        );
    _context.read<ConfBloc>().add(
          ConfUnsubscribed(),
        );
    _context.read<AccountsBloc>().add(
          AccountsUnsubscribed(),
        );
    await Future.delayed(const Duration(milliseconds: 300));
    await _context.read<AuthBloc>().signOut();
  }
}
