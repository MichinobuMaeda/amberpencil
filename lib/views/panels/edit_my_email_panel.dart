import 'package:amberpencil/blocs/auth_bloc.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import '../../config/theme.dart';
import '../../config/validators.dart';
import '../../blocs/accounts_bloc.dart';
import '../../config/l10n.dart';
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
          validator: emailValidator(context),
          confermationValidator: confermationValidator(context),
        ),
        child: Builder(
          builder: (context) => TextForm(
            label: L10n.of(context)!.email,
            itemName: L10n.of(context)!.email,
            style: const TextStyle(fontFamily: fontFamilyMonoSpace),
            onSave: (value) => () async {
              final AuthBloc authBloc = context.read<AuthBloc>();
              authBloc.updateMyEmail(value);
              await context.read<AccountsBloc>().updateMyAccount(
                {Account.fieldEmail: value},
              );
              authBloc.add(AuthUserReloaded());
            },
            resetOnSave: true,
          ),
        ),
      );
}
