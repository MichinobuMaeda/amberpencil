import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import '../../config/theme.dart';
import '../../config/validators.dart';
import '../../repositories/auth_repository.dart';
import '../theme_widgets/text_form.dart';
import '../theme_widgets/single_field_form_bloc.dart';

class ConfirmMyPasswordPanel extends StatelessWidget {
  const ConfirmMyPasswordPanel({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) => BlocProvider(
        key: ValueKey('${(ConfirmMyPasswordPanel).toString()}:password'),
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
        await context.read<AuthRepository>().reauthenticateWithPassword(value);
      };
}
