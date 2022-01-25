import 'package:flutter/material.dart';
import 'package:flutter_gen/gen_l10n/app_localizations.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import '../../config/theme.dart';
import '../../config/validators.dart';
import '../../blocs/auth_bloc.dart';
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
            label: AppLocalizations.of(context)!.password,
            password: true,
            style: const TextStyle(fontFamily: fontFamilyMonoSpace),
            saveButtonIcon: const Icon(Icons.check),
            saveButtonName: AppLocalizations.of(context)!.confirm,
            saveErrorMessage: AppLocalizations.of(context)!.errorReauthPassword,
            onSave: onConfirm(context),
          ),
        ),
      );

  Future<void> Function(
    String,
    VoidCallback,
  ) onConfirm(BuildContext context) => (
        String value,
        VoidCallback onError,
      ) async {
        await context.read<AuthBloc>().reauthenticateWithPassword(
              value,
              onError,
            );
      };
}
