import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import '../../config/theme.dart';
import '../../config/validators.dart';
import '../../models/app_state_provider.dart';
import '../../services/accounts_service.dart';
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
              context.read<AppStateProvider>().accountsService,
              context.read<AppStateProvider>().me!.id,
            ),
          ),
        ),
      );
}

TextFormOnSave onSaveEmail(
  AccountsService accountsService,
  String uid,
) =>
    (String value) async {
      await accountsService.updateAccountProperties(uid, {"email": value});
    };
