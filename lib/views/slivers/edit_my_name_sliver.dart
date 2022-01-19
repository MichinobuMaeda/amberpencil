import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import '../../blocs/my_account_bloc.dart';
import '../../config/validators.dart';
import '../../models/account.dart';
import '../../repositories/accounts_repository.dart';
import '../theme_widgets/box_sliver.dart';
import '../theme_widgets/text_form.dart';
import '../theme_widgets/single_field_form_bloc.dart';

class EditMyNameSliver extends StatelessWidget {
  const EditMyNameSliver({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) => BoxSliver(
        children: [
          BlocProvider(
            key: ValueKey(
              '${(EditMyNameSliver).toString()}:name:'
              '${context.watch<MyAccountBloc>().state.me!.name}',
            ),
            create: (context) => SingleFieldFormBloc(
              context.read<MyAccountBloc>().state.me!.name,
              validator: requiredValidator,
            ),
            child: Builder(
              builder: (context) => TextForm(
                label: '表示名',
                onSave: onSaveName(
                  context.read<AccountsRepository>(),
                  context.read<MyAccountBloc>().state.me!.id,
                ),
              ),
            ),
          ),
        ],
      );
}

TextFormOnSave onSaveName(
  AccountsRepository accountsRepository,
  String uid,
) =>
    (String value) async {
      await accountsRepository.updateMe(
        {Account.fieldName: value},
      );
    };
