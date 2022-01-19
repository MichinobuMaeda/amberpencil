import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import '../../config/theme.dart';
import '../../config/validators.dart';
import '../../models/account.dart';
import '../../repositories/accounts_repository.dart';
import '../theme_widgets/text_form.dart';
import '../theme_widgets/single_field_form_bloc.dart';

class EditMyEmailPanel extends StatelessWidget {
  const EditMyEmailPanel({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) => BlocProvider(
        key: ValueKey('${(EditMyEmailPanel).toString()}:email'),
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
              context.read<AccountsRepository>(),
            ),
          ),
        ),
      );
}

TextFormOnSave onSaveEmail(
  AccountsRepository accountsRepository,
) =>
    (String value) async {
      await accountsRepository.updateMe(
        {Account.fieldEmail: value},
      );
    };
