import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import '../../blocs/accounts_bloc.dart';

class AccountsSliver extends StatelessWidget {
  const AccountsSliver({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) => SliverList(
        delegate: SliverChildListDelegate(
          context
              .watch<AccountsBloc>()
              .state
              .map(
                (account) => SizedBox(
                  height: 32.0,
                  child: Text(account.name),
                ),
              )
              .toList(),
        ),
      );
}
