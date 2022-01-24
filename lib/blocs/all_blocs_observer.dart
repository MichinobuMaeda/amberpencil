import 'package:amberpencil/blocs/my_account_bloc.dart';
import 'package:flutter/widgets.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'auth_bloc.dart';
import '../models/account.dart';
import 'accounts_bloc.dart';
import 'conf_bloc.dart';
import 'groups_bloc.dart';
import 'my_account_bloc.dart';
import 'route_bloc.dart';

class AllBlocsObserver extends BlocObserver {
  final BuildContext _context;

  AllBlocsObserver(BuildContext context) : _context = context;

  @override
  void onChange(BlocBase bloc, Change change) {
    if (bloc is ConfBloc) {
      _context.read<AuthBloc>().add(AuthUrlChanged(change.nextState?.url));
      _context.read<RouteBloc>().add(OnConfUpdated(change.nextState));
    } else if (bloc is MyAccountBloc) {
      _context.read<RouteBloc>().add(OnMyAccountUpdated(change.nextState));

      if (change.currentState.me == null && change.nextState.me != null) {
        restoreAllUserData(change.nextState.me!);
      }
      if (change.currentState.me != null && change.nextState.me == null) {
        discardAllUserData();
      }
    } else if (bloc is AccountsBloc) {
      _context.read<MyAccountBloc>().add(OnAccountsUpdated(change.nextState));
    } else if (bloc is AuthBloc) {
      _context.read<MyAccountBloc>().add(OnAuthUserUpdated(change.nextState));
    }

    super.onChange(bloc, change);
  }

  void restoreAllUserData(Account me) {
    _context.read<AccountsBloc>().add(AccountsSubscribed(me));
    _context.read<ConfBloc>().add(ConfSubscribed(me));
    _context.read<GroupsBloc>().add(GroupsSubscribed(me));
  }

  Future<void> discardAllUserData() async {
    _context.read<GroupsBloc>().add(GroupsUnsubscribed());
    _context.read<ConfBloc>().add(ConfUnsubscribed());
    _context.read<AccountsBloc>().add(AccountsUnsubscribed());
    await Future.delayed(const Duration(milliseconds: 300));
    await _context.read<AuthBloc>().signOut();
  }
}
