import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import '../../config/theme.dart';
import '../../config/validators.dart';
import '../../models/app_state_provider.dart';
import '../widgets/text_form.dart';
import '../widgets/single_field_form_bloc.dart';

class ConfirmMyPasswordSection extends StatelessWidget {
  const ConfirmMyPasswordSection({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) => BlocProvider(
        key: ValueKey('${(ConfirmMyPasswordSection).toString()}:password'),
        create: (context) => SingleFieldFormBloc(
          '',
          validator: requiredValidator,
        ),
        child: Builder(
          builder: (context) => TextForm(
            label: 'パスワード',
            password: true,
            style: const TextStyle(fontFamily: fontFamilyMonoSpace),
            saveButtonIcon: const Icon(Icons.check),
            saveButtonName: '確認',
            saveErrorMessage: 'パスワードの確認ができませんでした。',
            onSave: onConfirm(context),
          ),
        ),
      );

  Future<void> Function(String) onConfirm(BuildContext context) =>
      (String value) async {
        await context
            .read<AppStateProvider>()
            .authService
            .reauthenticateWithPassword(value);
        context.read<AppStateProvider>().updateSignedInAt();
      };
}
