import 'package:flutter/material.dart';
import 'package:flutter_gen/gen_l10n/app_localizations.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import '../../blocs/accounts_bloc.dart';
import '../../blocs/my_account_bloc.dart';
import '../../config/validators.dart';
import '../../models/account.dart';
import '../theme_widgets/box_sliver.dart';
import '../theme_widgets/text_form.dart';
import '../helpers/single_field_form_bloc.dart';

class EditMyNameSliver extends StatelessWidget {
  const EditMyNameSliver({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) => BoxSliver(
        children: [
          BlocProvider(
            key: ValueKey(
              '$runtimeType:name:'
              '${context.watch<MyAccountBloc>().state.me!.name}',
            ),
            create: (context) => SingleFieldFormBloc(
              context.read<MyAccountBloc>().state.me!.name,
              validator: requiredValidator(context),
            ),
            child: Builder(
              builder: (context) => TextForm(
                label: AppLocalizations.of(context)!.displayName,
                onSave: onSaveName(
                  context.read<AccountsBloc>(),
                  context.read<MyAccountBloc>().state.me!.id,
                ),
              ),
            ),
          ),
        ],
      );
}

TextFormOnSave onSaveName(
  AccountsBloc accountsBloc,
  String uid,
) =>
    (String value, VoidCallback onError) async {
      accountsBloc.add(MyAccountChanged(Account.fieldName, value, onError));
    };
