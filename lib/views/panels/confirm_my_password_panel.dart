import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import '../../config/theme.dart';
import '../../config/validators.dart';
import '../../blocs/auth_bloc.dart';
import '../../config/l10n.dart';
import '../theme_widgets/text_form.dart';
import '../helpers/single_field_form_bloc.dart';

class ConfirmMyPasswordPanel extends StatelessWidget {
  const ConfirmMyPasswordPanel({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) => BlocProvider(
        key: ValueKey('$runtimeType:password'),
        create: (context) => SingleFieldFormBloc(
          '',
          validator: requiredValidator(context),
        ),
        child: Builder(
          builder: (context) => TextForm(
            label: L10n.of(context)!.password,
            errorMessage: L10n.of(context)!.errorReauthPassword,
            password: true,
            style: const TextStyle(fontFamily: fontFamilyMonoSpace),
            saveButtonIcon: const Icon(Icons.check),
            saveButtonName: L10n.of(context)!.confirm,
            onSave: (value) => () =>
                context.read<AuthBloc>().reauthenticateWithPassword(value),
          ),
        ),
      );
}
