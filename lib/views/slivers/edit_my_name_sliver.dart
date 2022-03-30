import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import '../../blocs/accounts_bloc.dart';
import '../../blocs/user_bloc.dart';
import '../../config/validators.dart';
import '../../config/l10n.dart';
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
              '${context.watch<UserBloc>().state.me?.name ?? ''}',
            ),
            create: (context) => SingleFieldFormBloc(
              context.read<UserBloc>().state.me?.name ?? '',
              validator: requiredValidator(context),
            ),
            child: Builder(
              builder: (context) => TextForm(
                label: L10n.of(context)!.displayName,
                onSave: (value) =>
                    () => context.read<AccountsBloc>().updateMyAccount(
                          {Account.fieldName: value},
                        ),
              ),
            ),
          ),
        ],
      );
}
