import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import '../../config/theme.dart';
import '../../config/validators.dart';
import '../../blocs/accounts_bloc.dart';
import '../../models/account.dart';
import '../theme_widgets/text_form.dart';
import '../helpers/single_field_form_bloc.dart';

class EditMyEmailPanel extends StatelessWidget {
  const EditMyEmailPanel({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) => BlocProvider(
        key: ValueKey('$runtimeType:email'),
        create: (context) => SingleFieldFormBloc(
          '',
          validator: emailValidator,
          confermationValidator: confermationValidator,
        ),
        child: Builder(
          builder: (context) => TextForm(
            label: 'メールアドレス',
            style: const TextStyle(fontFamily: fontFamilyMonoSpace),
            onSave: onSaveEmail(
              context.read<AccountsBloc>(),
            ),
          ),
        ),
      );
}

TextFormOnSave onSaveEmail(
  AccountsBloc accountsBloc,
) =>
    (
      String value,
      VoidCallback onError,
    ) async {
      accountsBloc.add(MyAccountChanged(Account.fieldEmail, value, onError));
    };
